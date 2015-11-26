class PostsController < ApplicationController

  def create
    @post = Post.new(post_params)
    if @post.save
      @channel = "/posts/new" # Type 0
      @type = params[:post][:channel_id]
      if params[:post][:channel_type].to_i == 1 # Course Post
        @channel = "/courses/#{params[:post][:channel_id]}/posts"
      elsif params[:post][:channel_type].to_i == 2 # Group Post
        @channel = "/groups/#{params[:post][:channel_id]}/posts"
      end
      PrivatePub.publish_to(@channel, message: @post)
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :user_id, :channel_type, :channel_id)
  end

end
