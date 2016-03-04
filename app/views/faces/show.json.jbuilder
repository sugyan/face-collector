json.extract! @face, :id
json.image_url image_face_url(@face)
json.photo do
  json.extract! @face.photo, :id, :uid, :photo_url, :source_url, :caption, :posted_at
end
