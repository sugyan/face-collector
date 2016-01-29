class AddColumnToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :twitter, :string
    add_column :labels, :ameblo, :string
  end
end
