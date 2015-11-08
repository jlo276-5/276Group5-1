class MessagesController < ApplicationController
  def index
    @messages = Message.take(30)
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      @channel = "/messages/new"
      @type = params[:message][:channel_id]
      if params[:message][:channel_type].to_i == 1
        @channel = "/courses/#{params[:message][:channel_id]}/messages"
      elsif params[:message][:channel_type].to_i == 2
        @channel = "/groups/#{params[:message][:channel_id]}/messages"
      end
      PrivatePub.publish_to(@channel, message: @message)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :user_id, :channel_type, :channel_id)
  end
end
