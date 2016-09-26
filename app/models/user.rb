class User < ActiveRecord::Base

  has_secure_password

  has_many :posts, dependent: :destroy

  validates :name, presence: true, uniqueness: true

end