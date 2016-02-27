json.extract! @label, :id, :name, :tags, :created_at, :updated_at
json.faces_count @label.faces.size
