class AddColumnsToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :caption, :text
    add_column :photos, :posted_at, :datetime
    change_table :photos do |table|
      table.rename :url, :source_url
      table.rename :media_url, :photo_url
    end
  end
end
