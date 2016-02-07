json.label_index @label.index_number
json.faces do
  json.array!(@faces) do |face|
    json.extract! face, :id
    json.image_url image_collector_face_url(face)
    json.image_size face.data.size
  end
end
