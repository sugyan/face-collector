class RemoveColumnsFromPhotos < ActiveRecord::Migration
  def change
    change_table :photos do |table|
      table.remove :user, :detected
    end
  end
end
