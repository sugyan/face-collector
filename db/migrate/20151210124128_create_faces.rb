class CreateFaces < ActiveRecord::Migration
  def change
    create_table :faces do |t|
      t.references :photo, index: true, foreign_key: true
      t.references :label, index: true, foreign_key: true
      t.binary :data

      t.timestamps null: false
    end
  end
end
