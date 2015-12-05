class AddFacesToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :faces, :json
  end
end
