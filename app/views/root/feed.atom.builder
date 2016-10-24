articles = {}
@faces.each do |face|
  next if face.updated_at >= Time.zone.now.beginning_of_hour
  key = face.updated_at.beginning_of_hour
  articles[key] = [] unless articles[key]
  articles[key] << face
end

atom_feed do |feed|
  feed.title 'Face Collector'
  feed.updated articles.keys.sort.last
  articles.keys.sort.reverse.each do |time|
    entries = articles[time]
    xml.entry do
      xml.id "tag:#{request.host},2005:face/#{time.xmlschema}"
      xml.title time
      xml.author do
        xml.name entries.map(&:edited_user).map(&:screen_name).uniq.join(', ')
      end
      xml.updated time.xmlschema
      xml.link rel: :alternate, type: 'text/html', href: feed_url
      xml.content do
        xml.div xmlns: 'http://www.w3.org/1999/xhtml' do |xhtml|
          entries.each do |entry|
            xhtml.p do
              xhtml.a "[#{entry.updated_at.to_s(:time)}] face #{entry.id}: #{entry.label.name} (#{entry.edited_user.screen_name})", href: face_url(entry)
            end
          end
        end
      end
    end
  end
end
