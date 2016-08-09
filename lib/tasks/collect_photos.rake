require 'open-uri'

namespace :collect_photos do
  desc 'TODO'

  task twitter: :common do
    client = HTTPClient.new
    # use application-only authentication
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    end
    twitter.middleware.insert(-1, Faraday::Response::Logger, logger)
    queries = Query.all.map(&:text)
    Label
      .enabled
      .where.not(twitter: nil)
      .where.not(twitter: '')
      .pluck(:twitter).uniq
      .sample(50)
      .each_slice(5) do |names|
      queries << names.map { |name| "from:#{name}" }.join(' OR ')
    end
    tweets = {}
    queries.each do |query|
      # search result doesn't include `extended_entities`.
      # so use `statuses/lookup` with search results.
      results = twitter.search("#{query} filter:images -filter:retweets", lang: 'ja', locale: 'ja').take(100)
      twitter.statuses(results, include_entities: true).each do |tweet|
        tweets[tweet.id.to_s] = tweet
      end
    end
    logger.info(format('%d tweets fetched', tweets.size))

    # detect faces and save
    size = (ENV['IMAGE_SIZE'] || '224').to_i
    tweets.each_value do |tweet|
      tweet.media.each do |media|
        logger.info(format('media %s', media.media_url_https))
        begin
          # check md5
          md5 = Digest::MD5.hexdigest(client.get(media.media_url_https).body)
          photo = Photo.find_or_initialize_by(md5: md5) do |p|
            p.uid = ['twitter', media.id].join(':')
            p.source_url = tweet.url
            p.photo_url = media.media_url_https
            p.posted_at = tweet.created_at
          end
          if photo.persisted?
            logger.info('already exist.')
            next
          end

          faces = photo.face_images(size)
          logger.info(format('%d faces detected', faces.size))
          if faces.present?
            photo.caption = format('%s (@%s): %s', tweet.user.name, tweet.user.screen_name, tweet.text)
            photo.faces << faces.map { |face| Face.new(data: face[:data]) }
          end
          photo.save
        rescue StandardError => e
          logger.warn(e)
        end
      end
    end
    logger.info('finished!')
  end
end
