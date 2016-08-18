json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :index_number
  json.label_url label_url(label)
  json.faces_count label.faces.size
  json.twitter label.twitter
end
