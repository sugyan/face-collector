# coding: utf-8
require 'open-uri'

namespace :search_idols do
  desc 'TODO'

  logger = Logger.new $stderr
  logger.level = Logger::INFO

  task cheerz: :environment do
    uri = 'https://cheerz.cz/'
    header = { 'Accept-Language': 'ja-JP' }
    client = HTTPClient.new
    Nokogiri::HTML(client.get_content(URI.join(uri, '/idols'), nil, header)).css('.idols ul.list li a').each do |a1|
      group = a1.text.strip
      logger.info(group)
      group_url = URI.join(uri, a1[:href])
      Nokogiri::HTML(client.get_content(group_url, nil, header)).css('.unitMember-List ul a').each do |a2|
        member_url = URI.join(uri, a2[:href])
        Nokogiri::HTML(client.get_content(member_url, nil, header)).css('.artistName').each do |name|
          li = name.css('li')
          name = li[1].text.gsub(/\s+/, '')
          kana = li[0].text.gsub(/\s+/, '').tr('ァ-ン', 'ぁ-ん')
          logger.info(format('%s (%s)', name, kana))
          Label.find_or_create_by(name: name) do |label|
            label.url = member_url
            label.description = group
            label.tags = kana
          end
        end
        sleep 1
      end
      sleep 1
    end
  end

  task dmmyell: :environment do
    uri = 'http://yell.dmm.com/'
    page = URI.join(uri, '/lp/list/idolplus/all/page:1/')
    client = HTTPClient.new
    loop do
      doc = Nokogiri::HTML(client.get_content(page))
      doc.css('.area-celebList-list .box-list').each do |box|
        group = box.css('header h2').text.strip
        logger.info(group)
        box.css('ul li').each do |li|
          name = li.css('.tit').text.strip
          sns = li.css('.sns a').first
          sns && twitter = sns[:href].sub('https://twitter.com/', '')
          Label.find_or_create_by(name: name) do |label|
            label.description = group
            label.twitter = twitter
          end
        end
      end
      next_arrow = doc.css('.arrow.next')
      break if next_arrow.empty?

      page = URI.join(uri, next_arrow.css('a').first[:href])
      sleep 1
    end
  end

  task speedland: :common do
    uri = ENV['SPEEDLAND_API_ENDPOINT']
    client = HTTPClient.new
    data = JSON.parse(client.get_content(URI.join(uri, '/hplink/api/artists/')))
    data.each do |artist|
      artist_name = artist['name']
      artist['members'].each do |member|
        name = member['name']
        graduation = Date.parse(member['graduationday'])
        if graduation > Date.new(1, 1, 1) && graduation < Date.today
          logger.info(format('%s is graduated', name))
          next
        end
        label = Label.find_or_initialize_by(name: name)
        if name != artist_name
          label.description = artist_name
        end
        label.save
        logger.info(label)
      end
    end
  end
end
