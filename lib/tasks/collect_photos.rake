require 'open-uri'

namespace :collect_photos do
  desc "TODO"

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task twitter: :environment do
    # use application-only authentication
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
    end
    client.middleware.insert(-1, Faraday::Response::Logger, logger)
    Query.all.each do |query|
      # search result doesn't include `extended_entities`.
      # so use `statuses/lookup` with search results.
      tweets = client.search("#{query.text} filter:images -filter:retweets", lang: 'ja', locale: 'ja').take(100)
      client.statuses(tweets, include_entities: true).each do |tweet|
        tweet.media.each do |media|
          uid = ['twitter', media.id].join(':')
          Photo.find_or_create_by(uid: uid) do |c|
            c.source_url = tweet.url
            c.photo_url = media.media_url_https
            c.caption = '%s(@%s): %s' % [tweet.user.name, tweet.user.screen_name, tweet.text]
            c.posted_at = tweet.created_at
          end
        end
      end
    end
  end

  task :ameblo, ['ameblo_id', 'months'] => :environment do |task, args|
    m = (args.months || '30').to_i
    today = Date.today
    (0 .. m - 1).each do |i|
      yyyymm = (today << i).strftime('%Y%m')
      url = "http://ameblo.jp/#{ args.ameblo_id }/imagelist-#{ yyyymm }.html"
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
