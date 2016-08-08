class RemoveJsonFromFaces < ActiveRecord::Migration
  def change
    change_table :faces do |table|
      table.remove :json
    end
  end
end
