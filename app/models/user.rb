class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :trackable
end
