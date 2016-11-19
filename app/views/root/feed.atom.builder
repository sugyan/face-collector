articles = {}
@faces.each do |face|
  next if face.updated_at >= Time.zone.now.beginning_of_hour
  key = face.updated_at.beginning_of_hour
  articles[key] = [] unless articles[key]
  articles[key] << face
end

atom_feed(root_url: feed_url) do |feed|
  feed.title 'Face Collector'
  feed.updated articles.keys.sort.last

  articles.keys.sort.reverse.each do |time|
    entries = articles[time][0, 20]
    xml.entry do
      xml.id "tag:#{request.host},2005:face/#{time.xmlschema}"
      xml.title time
      xml.author { xml.name entries.map(&:edited_user).map(&:screen_name).uniq.join(', ') }
      xml.updated time.xmlschema
      xml.link rel: :alternate, type: 'text/html', href: feed_url

      html = Builder::XmlMarkup.new
      html.img src: collage_faces_url(face_ids: entries.map(&:id).join('-'), size: 80)
      html.div do
        entries.each do |entry|
          html.text! "[#{entry.updated_at.to_s(:time)}] #{entry.id}: #{entry.label.name} (#{entry.edited_user.screen_name})"
          html.br
        end
        if entries.size > 30
          html.text! '...'
          html.br
        end
      end
      xml.content html.target!, type: :html
    end
  end
end
