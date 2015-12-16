json.array!(@queries) do |query|
  json.extract! query, :id, :text, :executed
  json.url query_url(query, format: :json)
end
