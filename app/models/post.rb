class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :comments

  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user
  
end
