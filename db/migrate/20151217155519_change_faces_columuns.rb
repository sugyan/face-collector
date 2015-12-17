class ChangeFacesColumuns < ActiveRecord::Migration
  def change
    change_table :faces do |table|
      table.change :photo_id, :integer
    end
  end
end
