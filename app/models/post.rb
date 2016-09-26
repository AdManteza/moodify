class Post < ActiveRecord::Base

  belongs_to :user

  validates :url_one, :url_two, :url_three, :url_four, presence: true
end