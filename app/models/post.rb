class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :comments

  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user

  validates :image, presence: true
  validates :description, length: { maximum: 200 }
  validate :image_format

  private

  def image_format
    if image.attached? && !image.content_type.in?(%('image/jpeg image/png'))
      errors.add(:image, 'must be a JPEG or PNG')
    end
  end
end
