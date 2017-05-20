json.faces @faces.map do |face|
  json.extract! face, :id, :label_id, :photo_id
  json.image_url image_face_url(face)
end
json.page do
  json.prev @faces.prev_page && url_for(page: @faces.prev_page, format: :json, only_path: false)
  json.next @faces.next_page && url_for(page: @faces.next_page, format: :json, only_path: false)
end
