json.extract! @label, :id, :name, :description, :created_at, :updated_at
json.faces_count @label.faces.size
