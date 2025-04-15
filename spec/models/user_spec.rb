require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.find_for_database_authentication' do
    let!(:user) { create(:user, username: 'testuser', email: 'test@example.com') }

    context 'when login matches username (case insensitive)' do
      it 'finds the user' do
        result = User.find_for_database_authentication(login: 'TestUser')
        expect(result).to eq(user)
      end
    end

    context 'when login matches email (case insensitive)' do
      it 'finds the user' do
        result = User.find_for_database_authentication(login: 'TEST@example.com')
        expect(result).to eq(user)
      end
    end

    context 'when login does not match' do
      it 'returns nil' do
        result = User.find_for_database_authentication(login: 'notfound')
        expect(result).to be_nil
      end
    end

    context 'when conditions contain only username' do
      it 'finds user by exact username' do
        result = User.find_for_database_authentication(username: 'testuser')
        expect(result).to eq(user)
      end

      it 'finds user by exact email' do
        result = User.find_for_database_authentication(email: 'test@example.com')
        expect(result).to eq(user)
      end
    end
  end
end
