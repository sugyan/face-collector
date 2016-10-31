class AddAdminFlagToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_admin, :boolean
  end
end
