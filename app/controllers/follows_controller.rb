class FollowsController < ApplicationController
  def create
    user = User.find_by!(username: params[:username])
    current_user.active_follows.create!(followed_id: user.id)
    render json: { followers_count: user.followers.count }
  end

  def destroy
    user = User.find_by!(username: params[:username])
    current_user.active_follows.find_by!(followed_id: user.id).destroy
    render json: { followers_count: user.followers.count }
  end
end