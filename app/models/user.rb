class User < ApplicationRecord
  attr_accessor :login

  has_one_attached :avatar
  has_many :posts
  has_many :comments

  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  has_many :active_follows, class_name: "Follow", 
                            foreign_key: "follower_id",
                            dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, class_name: "Follow", 
                             foreign_key: "followed_id",
                             dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:login]

  validates :username, presence: true,
            uniqueness: true,
            length: { maximum: 24 },
            format: { with: /\A[a-z0-9]+\z/, message: "must be a unique 24 length lowercase latin/number value" }

  validates :email, presence: true, 
            uniqueness: true,
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "must contain '@'" }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    
    if login
      where(conditions.to_h).where(
        ["lower(username) = :value OR lower(email) = :value", 
        { value: login.downcase }]
      ).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def to_param
    username
  end
end
