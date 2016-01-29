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
  end
end
