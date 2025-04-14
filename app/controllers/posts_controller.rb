class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    @filter = params[:filter] || "all"

    posts_scope = if @filter == "following" && current_user
                    Post.where(user_id: current_user.following_ids)
                  else
                    Post.all
                  end
  
    @posts = posts_scope
      .includes(:user, :likes, image_attachment: :blob)
      .with_attached_image
      .order(created_at: :desc)
      .paginate(page: params[:page], per_page: 20)
  
    @liked_post_ids = current_user.liked_posts.pluck(:id)
  end

  def show
    @post = Post.includes(:user, :likes, image_attachment: :blob)
      .with_attached_image
      .find(params[:id])
    @comments = @post.comments.includes(:user).order(created_at: :desc)
    @post_liked = @post.likes.exists?(user_id: current_user.id)
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find(params[:id])
    redirect_to root_path unless @post.user == current_user
  end

  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save

        CompressImageJob.perform_later(@post.id)
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_post
      @post = Post.find(params.expect(:id))
    end

    def post_params
      params.expect(post: [ :user_id, :description, :image ]).merge({ user_id: current_user.id })
    end
end
