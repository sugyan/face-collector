json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :tags, :twitter
  json.url label_url(label)
end
json.array!(
  [
    {
      id: -1,
      name: 'Not Target',
      tags: 'nottarget'
    }
  ]
)
