class UpdateUsersAuthenticationTokenIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :authentication_token
    add_index :users, :authentication_token, unique: false
  end
end
