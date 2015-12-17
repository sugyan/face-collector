class AddColumnsToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :description, :text
    add_column :labels, :url, :string
    add_column :labels, :order_number, :integer
    add_index :labels, :order_number, unique: true
  end
end
