FactoryBot.define do
  factory :user do
    username { FFaker::Internet.user_name.gsub(/[^a-z0-9]/i, '').downcase[0, 24] }
    email { FFaker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
