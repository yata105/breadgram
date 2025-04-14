class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @posts = @user.posts.select(:id).order(created_at: :desc)
      .paginate(page: params[:page], per_page: 20).with_attached_image
    @followed = current_user.active_follows.exists?(followed_id: @user.id)

    @posts_count = @user.posts.size
    @followers_count = @user.followers.size
    @following_count = @user.following.size
  end

  def index
    @users = User.all.paginate(page: params[:page], per_page: 20)
  end

  def settings
  end
end