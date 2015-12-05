namespace :collect_images do
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
    # search result doesn't include `extended_entities`.
    # so use `statuses/lookup` with search results.
    tweets = client.search('#CHEERZ filter:images -filter:retweets', lang: 'ja', locale: 'ja').take(100)
    client.statuses(tweets, include_entities: true).each do |tweet|
      tweet.media.each do |media|
        Photo.find_or_create_by(id: media.id) do |c|
          c.user = tweet.user.name
          c.url = tweet.url
          c.media_url = media.media_url_https
        end
      end
    end
  end

end
