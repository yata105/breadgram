require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  let!(:toggle_follow_user) { create :user }

  describe '#create' do
    subject { post :create, params: { username: toggle_follow_user.username } }

    context 'when user is not logged in' do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      let(:user) { create :user }

      before { sign_in user }

      it 'returns 200' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'creates new follow record' do
        expect {
          subject
        }.to change(Follow, :count).by(1)
      end
    end
  end

  describe '#destroy' do
    let(:user) { create :user }    
    
    subject { 
      delete :destroy, params: { 
        id: toggle_follow_user.id, username:  toggle_follow_user.username 
      } 
    }

    before { 
      create(:follow, follower: user, followed: toggle_follow_user)
    }

    context 'when user is not logged in' do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      before { sign_in user }

      it 'returns 200' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'deletes follow record' do
        expect {
          subject
        }.to change(Follow, :count).by(-1)
      end
    end

  end
end