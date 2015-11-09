class MessagesController < ApplicationController
  before_action :super_user, only: [:index]
  layout 'blank'

  def index
    @messages = Message.where(channel_type: -1..2).last(30)
    @posts = Message.where(channel_type: 3..5).last(30)
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      @channel = "/messages/new"
      @type = params[:message][:channel_id]
      if params[:message][:channel_type].to_i == 1 # Course Chat
        @channel = "/courses/#{params[:message][:channel_id]}/messages"
      elsif params[:message][:channel_type].to_i == 2 # Group Chat
        @channel = "/groups/#{params[:message][:channel_id]}/messages"
      elsif params[:message][:channel_type].to_i == 3
        @channel = "/posts/new"
      elsif params[:message][:channel_type].to_i == 4 # Course Post
        @channel = "/courses/#{params[:message][:channel_id]}/posts"
      elsif params[:message][:channel_type].to_i == 5 # Group Post
        @channel = "/groups/#{params[:message][:channel_id]}/posts"
      end
      PrivatePub.publish_to(@channel, message: @message)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :user_id, :channel_type, :channel_id)
  end

  def super_user
    unless current_user.superuser?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
    end
  end
end
