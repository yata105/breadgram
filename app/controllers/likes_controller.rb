class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    current_user.likes.create!(post:)
    render json: { likes_count: post.likes.count }
  end

  def destroy
    post = Post.find(params[:post_id])
    current_user.likes.find_by(post:)&.destroy
    render json: { likes_count: post.likes.count }
  end
end