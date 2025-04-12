class CommentsController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    comment = post.comments.create!(comment_params.merge(user: current_user))

    render json: {
      success: true,
      comment: {
        id: comment.id,
        value: comment.value,
        username: comment.user.username,
        avatar_url: ActionController::Base.helpers.asset_path('profile.svg'),
        delete_url: ActionController::Base.helpers.asset_path('delete.svg'),
        date: comment.created_at.to_date,
      }
    }
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
      render json: { success: true }
    else
      render json: { success: false, error: "Not authorized" }, status: :unauthorized
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:value)
  end
end