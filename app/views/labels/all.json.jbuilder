json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :tags, :twitter
  json.url url_for(label)
end
json.array!([
  {
    id: nil,
    name: 'Remove label',
    tags: 'remove'
  }
])
