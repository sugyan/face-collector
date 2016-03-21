class AddMd5ColumnToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :md5, :string
    add_index :photos, :md5, unique: true
  end
end
