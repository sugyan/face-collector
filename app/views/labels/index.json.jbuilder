# coding: utf-8
@labels << {
  id: nil,
  name: 'Remove label',
  tags: 'remove'
}
json.array!(@labels) do |label|
  json.extract! label, :id, :name, :tags
end
