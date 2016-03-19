class CreateInferences < ActiveRecord::Migration
  def change
    create_table :inferences do |t|
      t.references :face, index: true, foreign_key: true
      t.references :label, index: true, foreign_key: true
      t.float :score

      t.timestamps null: false

      t.index [:face_id, :label_id], unique: true
    end
  end
end
