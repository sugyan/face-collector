json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :tags, :twitter
end
json.array!([
  {
    id: nil,
    name: 'Remove label',
    tags: 'remove'
  }
])
