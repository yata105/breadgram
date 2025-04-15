require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#index' do
    subject { get :index }

    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      let(:user) { create :user }
      
      before { sign_in user }

      it 'returns 200 and renders index template' do
        subject
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end
    end
  end

  describe '#show' do
    let(:visited_user) { create :user }
    subject { get :show, params: { username: visited_user.username } }
    
    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      let(:user) { create :user }
      let!(:posts) { create_list(:post, 3, user: visited_user) }

      let!(:followers) { create_list(:user, 3) }
      let!(:following_visited_user) do
        followers.map { |follower| create(:follow, follower: follower, followed: visited_user) }
      end
      let!(:visited_user_followed) do
        followers.map { |follower| create(:follow, follower: visited_user, followed: follower)}
      end

      before { sign_in user }

      it 'returns 200 and renders show template' do
        subject
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end

      it 'assigns visited user posts and posts count' do
        subject
        expect(assigns(:posts)).to match_array(Post.order(created_at: :desc))
        expect(assigns(:posts_count)).to eq(posts.size)
      end

      it 'assigns followers and following count' do
        subject
        expect(assigns(:followers_count)).to eq(following_visited_user.size)
        expect(assigns(:following_count)).to eq(visited_user_followed.size)
      end
    end
  end

  describe '#settings' do
    subject { get :settings }

    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      let(:user) { create :user }
      
      before { sign_in user }

      it 'returns 200 and renders settings template' do
        subject
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:settings)
      end
    end
  end
end