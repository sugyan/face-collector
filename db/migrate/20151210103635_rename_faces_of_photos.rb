class RenameFacesOfPhotos < ActiveRecord::Migration
  def change
    change_table :photos do |table|
      table.rename :faces, :detected
    end
  end
end
