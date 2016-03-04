json.array!(@labels) do |label|
  json.extract! label, :id, :name, :description, :index_number
end
