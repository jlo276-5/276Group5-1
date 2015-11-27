class PostsController < ApplicationController
  before_action :correct_user, except: :create

  def create
    @post = Post.new(post_params)
    if @post.save
      @channel = channel_for_post(@post)
      PrivatePub.publish_to(@channel, message: @post)
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(post_params)
      @channel = channel_for_post(@post)
      PrivatePub.publish_to(@channel, message: @post)
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if @post.destroy
      @channel = channel_for_post(@post)
      PrivatePub.publish_to(@channel, message: @post)
    end
  end

  private

  def correct_user
    @post = Post.find(params[:id])
    unless current_user == @post.user or current_user.admin?
      respond_to do |format|
        format.js {render 'improper' }
      end
    end
  end

  def channel_for_post(post)
    if post.channel_type == 1 # Course Post
      channel = "/courses/#{post.channel_id}/posts"
    elsif post.channel_type == 2 # Group Post
      channel = "/groups/#{@post.channel_id}/posts"
    else
      channel = "/posts/new"
    end
  end

  def post_params
    params.require(:post).permit(:title, :body, :user_id, :channel_type, :channel_id)
  end

end
