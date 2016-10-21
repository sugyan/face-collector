xml.instruct! :xml, :version => "1.0"
xml.rss version: "2.0", :"xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Face Collector"
    xml.link "#{request.scheme}://#{request.host}/"
    xml.description ""
    xml.atom :link, href: "#{request.scheme}://#{request.host}/feed.rss", rel: "self", type: "application/rss+xml"

    for face in @faces
      xml.item do
        xml.title face.id
        xml.guid face_url(face), isPermaLink: true
        xml.pubDate face.updated_at.to_formatted_s(:rfc822)
        xml.author "#{face.edited_user.email} (#{face.edited_user.screen_name})"
        xml.enclosure url: image_face_url(face), length: face.data.size, type: "image/jpeg"
      end
    end
  end
end