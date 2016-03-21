require 'open-uri'

namespace :collect_photos do
  desc 'TODO'

  task twitter: :common do
    # use application-only authentication
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    end
    client.middleware.insert(-1, Faraday::Response::Logger, logger)
    queries = Query.all.map(&:text)
    Label
      .where.not(twitter: nil)
      .where.not(twitter: '')
      .pluck(:twitter).uniq
      .sample(40)
      .each_slice(8) do |names|
      queries << names.map { |name| "from:#{name}" }.join(' OR ')
    end
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
          faces = photo.face_images(size)
          logger.info(format('%d faces detected', faces.size))
          if faces.present?
            photo.faces << faces.map { |face| Face.new(data: face[:data], json: face[:json]) }
            photo.save
          end
        rescue StandardError => e
          logger.warn(e)
        end
      end
    end
  end
end
