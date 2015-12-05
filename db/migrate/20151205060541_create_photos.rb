class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos, { id: :bigint } do |t|
      t.string :user
      t.text :url
      t.text :media_url

      t.timestamps null: false
    end
  end
end
