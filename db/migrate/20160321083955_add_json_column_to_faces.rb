class AddJsonColumnToFaces < ActiveRecord::Migration
  def change
    add_column :faces, :json, :json
  end
end
