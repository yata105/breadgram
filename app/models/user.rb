class User < ApplicationRecord
  attr_accessor :login

  has_one_attached :avatar
  has_many :posts
  has_many :comments

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

  validates :username, presence: true, format: { without: /@/, message: "can\`t contain @" }
  validates :email, presence: true, uniqueness: true

  def self.find_for_database_authentication(warden_conditions)
    Rails.logger.info "!!! Auth conditions: #{warden_conditions.inspect} !!!"
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

  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def thumbnail
    avatar.variant(resize_to_limit: [48, 48]).processed
  end
end
