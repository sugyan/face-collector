require 'open-uri'

namespace :collect_photos do
  include Image

  desc 'TODO'

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task twitter: :environment do
    # use application-only authentication
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
    end
    client.middleware.insert(-1, Faraday::Response::Logger, logger)
    queries = Query.all.map(&:text)
    screen_names = Label
      .where.not(twitter: nil)
      .where.not(twitter: '')
      .pluck(:twitter).uniq
      .sample(5)
    queries << screen_names.map { |name| "from:#{name}" }.join(' OR ')
    tweets = {}
    queries.each do |query|
      # search result doesn't include `extended_entities`.
      # so use `statuses/lookup` with search results.
      results = client.search("#{query} filter:images -filter:retweets", lang: 'ja', locale: 'ja').take(100)
      client.statuses(results, include_entities: true).each do |tweet|
        tweets[tweet.id.to_s] = tweet
      end
    end
    logger.info(format('%d tweets fetched', tweets.size))

    # detect faces and save
    size = (ENV['IMAGE_SIZE'] || '224').to_i
    tweets.each_value do |tweet|
      tweet.media.each do |media|
        uid = ['twitter', media.id].join(':')
        next if Photo.find_by(uid: uid)

        photo = Photo.new do |c|
          c.uid = uid
          c.source_url = tweet.url
          c.photo_url = media.media_url_https
          c.caption = format('%s (@%s): %s', tweet.user.name, tweet.user.screen_name, tweet.text)
          c.posted_at = tweet.created_at
        end
        begin
          faces = detect_faces(photo.photo_url, size)
          img = photo.image
          logger.info(format('%d faces detected', faces.size))
          photo.faces << faces.map { |face| Face.new(data: face_image(img, face, size)) }
          photo.save if photo.faces.present?
          img.destroy!
        rescue SignalException => e
          raise e
        end
      end
    end
  end

  task :ameblo, %w(ameblo_id months) => :environment do |_task, args|
    m = (args.months || '30').to_i
    today = Time.zone.today
    (0..m - 1).each do |i|
      yyyymm = (today << i).strftime('%Y%m')
      url = "http://ameblo.jp/#{args.ameblo_id}/imagelist-#{yyyymm}.html"
      logger.info(url)
      doc = Nokogiri::HTML(open(url))
      doc.css('#imgList .imgLink').each do |li|
        # scan javascript tag... and parse JSON
        image_url = li[:href]
        logger.info(image_url)
        targets = Nokogiri::HTML(open(image_url)).css('script').select do |script|
          script.text.match(/imgData/)
        end
        data = JSON.parse(targets.first.text.scan(/{.*}/m)[0])
        images = data['imgData']['next']['imgList'].concat(data['imgData']['current']['imgList'])
        images.each do |image|
          uid = ['ameblo', args.ameblo_id, image['imgUrl'].split('/').last.split('.').first].join(':')
          Photo.find_or_create_by(uid: uid) do |p|
            p.source_url = URI(data['pageDomain'] + image['pageUrl']).to_s
            p.photo_url = URI(data['imgDetailDomain'] + image['imgUrl']).to_s
            p.caption = image['title']
            p.posted_at = image['date']
          end
        end
        sleep 1
      end
    end
  end
end
