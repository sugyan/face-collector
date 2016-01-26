@labels << {
  id: nil,
  name: 'Remove label',
  tags: 'remove',
  index_number: nil
}
json.array!(@labels) do |label|
  json.extract! label, :id, :name, :tags, :index_number
end
