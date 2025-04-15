require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create :user }
  let(:post_record) { create(:post, user: user) }

  describe '#create' do
    subject { post :create, params: { post_id: post_record.id, comment: { value: FFaker::Lorem.sentence } } }

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

      it 'creates new comment record' do
        expect {
          subject
        }.to change(Comment, :count).by(1)
      end
    end
  end

  describe '#destroy' do
    let!(:comment) { create(:comment, user: user, post: post_record) }
    subject { delete :destroy, params: { post_id: post_record.id, id: comment.id } }

    context 'when user is not logged in' do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      context 'when user owns post' do
        before { sign_in user }

        it 'returns 200' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'deletes comment' do
          expect {
            subject
          }.to change(Comment, :count).by(-1)
        end
      end

      context 'when user doesnt own post' do
        let(:another_user) { create :user }

        before { sign_in another_user }

        it 'returns 401' do
          subject
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end