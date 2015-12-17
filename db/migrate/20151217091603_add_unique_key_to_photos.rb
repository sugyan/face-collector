class AddUniqueKeyToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :uid, :string
    add_index :photos, :uid, unique: true
  end
end
