class AddRejectedFlagToInferences < ActiveRecord::Migration[5.0]
  def change
    add_column :inferences, :rejected, :boolean, null: false, default: false
    add_index :inferences, :rejected
  end
end
