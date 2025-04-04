class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts
  has_many :comments
  
  attr_accessor :login

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

  def thumbnail
    avatar.variant(resize_to_limit: [48, 48]).processed
  end
end
