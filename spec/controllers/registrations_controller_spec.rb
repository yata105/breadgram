require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  describe "POST /users" do
    let(:user_params) do
      {
        user: {
          username: "testuser",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates a new user" do
      expect {
        post user_registration_path, params: user_params
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it "does not log in the user automatically" do
      post user_registration_path, params: user_params

      expect(controller.current_user).to be_nil
    end
  end
end
