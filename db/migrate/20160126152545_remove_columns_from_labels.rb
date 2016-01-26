class RemoveColumnsFromLabels < ActiveRecord::Migration
  def change
    change_table :labels do |table|
      table.remove :order_number
    end
  end
end
