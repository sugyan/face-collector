class User < ApplicationRecord
  acts_as_token_authenticatable
  devise :database_authenticatable, :rememberable, :trackable
end
