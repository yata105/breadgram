require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe '#index' do
    subject { get :index }

    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      let(:user) { create :user }

      before { sign_in user }

      context 'with all filter' do
        let(:posts) { create_list(:post, 3) }
        let(:liked_post) { create :post }

        before { create(:like, user: user, post: liked_post) }

        it 'returns 200 and renders index page' do
          subject
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:index)
        end
  
        it 'assigns posts and liked_post_ids' do
          subject
          expect(assigns(:posts)).to match_array(Post.order(created_at: :desc))
          expect(assigns(:liked_post_ids)).to include(liked_post.id)
        end
      end

      context 'with following filter' do
        let(:followed_user) { create :user }
        let!(:followed_post) { create(:post, user: followed_user) }
      
        before { user.following << followed_user }
      
        it 'returns posts from followed users' do
          get :index, params: { filter: 'following' }
          expect(assigns(:posts)).to include(followed_post)
        end
      end
    end
  end

  describe '#show' do
    let(:post) { create :post }

    subject { get :show, params: { id: post.id } }
      
    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      let(:user) { create :user }
      let(:comments) { create_list(:comment, 3, user: user, post: post) }

      before do 
        sign_in user
        create(:like, user: user, post: post)
      end

      it 'returns 200 and renders show template' do
        subject
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end

      it 'assigns post comments and liked status' do 
        subject
        expect(assigns(:comments)).to match_array(Comment.order(created_at: :desc))
        expect(assigns(:post_liked)).to be true
      end
    end
  end

  describe '#new' do
    subject { get :new }

    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      let(:user) { create :user }

      before do 
        sign_in user
      end

      it 'returns 200 and renders new template' do
        subject
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#edit' do
    let(:user) { create :user }
    let(:post) { create(:post, user: user) }

    subject { get :edit, params: { id: post.id } }

    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        subject
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in', :aggregate_failures do
      context 'user owns post' do
        before do 
          sign_in user
        end
  
        it 'returns 200 and renders edit template' do
          subject
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:edit)
        end
      end

      context 'user doesnt own post' do
        let(:another_user) { create :user }
  
        before do
          sign_in another_user
        end
  
        it 'redirects to root path' do
          subject
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe '#create' do
    let(:user) { create :user }

    context 'when user is not logged in', :aggregate_failures do
      it 'redirects to log in form' do
        post :create, params: { post: { description: 'Test post' } }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      before { sign_in user }

      context 'with valid attributes' do
        let(:valid_params) do
          {
            post: {
              description: 'Test description',
              image: fixture_file_upload(Rails.root.join('spec/fixtures/files/sample_image.jpg'), 'image/jpeg')
            }
          }
        end

        it 'creates a new post' do
          expect {
            post :create, params: valid_params
          }.to change(Post, :count).by(1)
        end

        it 'redirects to post page' do
          post :create, params: valid_params
          expect(response).to redirect_to(post_path(Post.last))
        end
      end

      context 'with invalid attributes' do
        let(:invalid_params) do
          { post: { description: '' } }
        end

        it 'does not create a post' do
          expect {
            post :create, params: invalid_params
          }.not_to change(Post, :count)
        end

        it 'renders new template and returns unprocessable entity' do
          post :create, params: invalid_params
          expect(response).to render_template(:new)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user, description: 'Old description') }

    context 'when user is not logged in' do
      it 'redirects to login' do
        patch :update, params: { id: post.id, post: { description: 'Updated' } }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is logged in' do
      before { sign_in user }
      
      it 'updates the post' do
        patch :update, params: { id: post.id, post: { description: 'Updated description' } }
        expect(post.reload.description).to eq('Updated description')
      end

      it 'redirects to the post or feed' do
        patch :update, params: { id: post.id, post: { description: 'Updated description' } }
        expect(response).to redirect_to(post_path(post))
      end
    end
  end
end