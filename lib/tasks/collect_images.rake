namespace :collect_images do
  desc "TODO"
  task twitter: :environment do
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
    end
    client.search('#CHEERZ filter:images -filter:retweets', lang: 'ja', locale: 'ja', include_entities: true).take(30).each do |tweet|
      tweet.media.each do |media|
        p '%s -> %s' % [tweet.url, media.media_url_https]
      end
    end
  end

end
