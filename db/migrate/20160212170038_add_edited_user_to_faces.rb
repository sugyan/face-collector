class AddEditedUserToFaces < ActiveRecord::Migration
  def change
    add_column :faces, :edited_user_id, :integer
    add_index :faces, :edited_user_id
  end
end
