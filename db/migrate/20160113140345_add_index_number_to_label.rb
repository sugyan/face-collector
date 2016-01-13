class AddIndexNumberToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :index_number, :integer
    add_index :labels, :index_number, unique: true
  end
end
