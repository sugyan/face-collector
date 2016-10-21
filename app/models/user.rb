class User < ApplicationRecord
  acts_as_token_authenticatable
  devise :database_authenticatable, :rememberable, :trackable

  has_many :faces, foreign_key: :edited_user_id
end
