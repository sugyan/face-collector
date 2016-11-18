class AddNoteColumnToLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :note, :text
  end
end
