class User < ApplicationRecord
  attr_accessor :login

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, format: { without: /@/, message: "can\`t contain @" }
  validates :email, presence: true, uniqueness: true

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(
        ["lower(username) = :value OR lower(email) = :value", 
         { value: login.downcase }]
      ).first
    else
      where(conditions).first
    end
  end
end
