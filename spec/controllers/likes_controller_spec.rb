require 'rails_helper'

RSpec.describe LikesController, type: :controller do 
  let(:user) { create :user }
  let(:post_record) { create(:post, user: user) }

  describe '#create' do
    subject { post :create, params: { post_id: post_record.id } }

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

      it 'creates like record' do
        expect {
          subject
        }.to change(Like, :count).by(1)
      end
    end
  end

  describe '#destroy' do
    subject { delete :destroy, params: { post_id: post_record.id } }

    context 'when user is not logged in' do
      before { create(:like, user: user, post: post_record) }

      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      before { sign_in user }

      context 'when like exists' do
        before { create(:like, user: user, post: post_record) }

        it 'returns 200' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'deletes like record' do
          expect {
            subject
          }.to change(Like, :count).by(-1)
        end
      end

      context 'when like does not exist', :aggregate_failures do
        it 'returns 200' do
          subject
          expect(response).to have_http_status(:success)
        end
      
        it 'does not delete like record' do
          expect {
            subject
          }.not_to change(Like, :count)
        end
      end
    end
  end
end