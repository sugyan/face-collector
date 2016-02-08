json.faces @faces.map do |face|
  json.extract! face, :id, :label_id, :photo_id
  json.image_url image_collector_face_url(face)
end
json.page do
  json.prev @faces.prev_page && collector_faces_url(page: @faces.prev_page, format: :json)
  json.next @faces.next_page && collector_faces_url(page: @faces.next_page, format: :json)
end