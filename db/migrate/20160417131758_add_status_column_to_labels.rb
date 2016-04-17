class AddStatusColumnToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :status, :int, null: false, default: 1
    add_index :labels, :status
  end
end
