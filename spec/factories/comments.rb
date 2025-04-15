FactoryBot.define do
  factory :comment do
    user
    post
    value { FFaker::Lorem.sentence }
  end
end