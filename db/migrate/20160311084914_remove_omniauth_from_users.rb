class RemoveOmniauthFromUsers < ActiveRecord::Migration
  def change
    change_table :users do |table|
      table.remove :provider, :uid
    end
    add_index :users, :email, unique: true
  end
end
