require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  context 'image validations' do
    it 'is valid with a JPEG image' do
      post = Post.new(
        user: user,
        description: 'Test',
        image: fixture_file_upload('sample_image.jpg', 'image/jpeg')
      )
      expect(post).to be_valid
    end

    it 'is valid with a PNG image' do
      post = Post.new(
        user: user,
        description: 'Test',
        image: fixture_file_upload('sample_image.png', 'image/png')
      )
      expect(post).to be_valid
    end

    it 'is invalid with a non-image file' do
      post = Post.new(
        user: user,
        description: 'Test',
        image: fixture_file_upload('sample_file.pdf', 'application/pdf')
      )
      expect(post).not_to be_valid
      expect(post.errors[:image]).to include('must be a JPEG or PNG')
    end

    it 'is invalid without an image' do
      post = Post.new(
        user: user,
        description: 'Test'
      )
      expect(post).not_to be_valid
      expect(post.errors[:image]).to include("can't be blank")
    end
  end
end