class UpdateIndexOfInference < ActiveRecord::Migration
  def change
    remove_index :inferences, [:face_id, :label_id]
    remove_index :inferences, :face_id
    add_index :inferences, :face_id, unique: true
  end
end
