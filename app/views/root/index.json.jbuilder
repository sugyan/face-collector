json.labels do
  json.array!(@labels) do |label|
    json.extract! label, :id, :index_number, :name, :description, :url, :twitter
    json.label_url label_url(label)
    json.faces_count label.faces.size
  end
end
json.page do
  json.prev @ids.prev_page && root_url(page: @ids.prev_page, format: :json)
  json.next @ids.next_page && root_url(page: @ids.next_page, format: :json)
end
