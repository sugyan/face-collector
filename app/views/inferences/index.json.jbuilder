json.inferences @inferences.map do |inference|
  json.extract! inference, :id, :score, :updated_at
  json.face do
    json.extract! inference.face, :id
    json.image_url image_face_url(inference.face)
    json.photo do
      json.extract! inference.face.photo, :source_url, :photo_url, :caption, :posted_at
    end
  end
  json.label do
    json.extract! inference.label, :id, :name, :description, :twitter
  end
end
json.page do
  json.prev @inferences.prev_page && url_for(page: @inferences.prev_page, format: :json, only_path: false)
  json.next @inferences.next_page && url_for(page: @inferences.next_page, format: :json, only_path: false)
end
