class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.select(:id).with_attached_image

    @posts_count = @user.posts.size
    @followers_count = @user.followers.size
    @following_count = @user.following.size
  end
end