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
      @channel = "/messages/new" # Type 0
      if @message.channel_type == 1 # Course Chat
        @channel = "/courses/#{@message.channel_id}/messages"
      elsif @message.channel_type == 2 # Group Chat
        @channel = "/groups/#{@message.channel_id}/messages"
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
      flash[:danger] = "You do not have the permission to see that."
      redirect_to home_path
    end
  end
end
