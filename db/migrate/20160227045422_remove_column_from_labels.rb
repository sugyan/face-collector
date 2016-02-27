class RemoveColumnFromLabels < ActiveRecord::Migration
  def change
    change_table :labels do |table|
      table.remove :ameblo
    end
  end
end
