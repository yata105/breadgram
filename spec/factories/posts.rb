FactoryBot.define do
  factory :post do
    user
    description { FFaker::Lorem.sentence }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample_image.jpg'), 'image/jpeg') }
  end
end
