json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :tags, :twitter
  json.url collector_label_url(label)
end
json.array!([
  {
    id: nil,
    name: 'Remove label',
    tags: 'remove'
  },
  {
    id: -1,
    name: 'Not Face',
    tags: 'notface'
  }
])
