json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :twitter, :index_number
  json.label_url label_url(label)
  json.faces_count label.faces.size
end
