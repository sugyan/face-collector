class ChangeFacesColumuns < ActiveRecord::Migration
  def change
    change_table :faces do |table|
      table.change :photo_id, :bigint
    end
  end
end
