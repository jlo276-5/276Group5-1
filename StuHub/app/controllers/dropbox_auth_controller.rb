class DropboxAuthController < ApplicationController
  before_filter :allowed_user, only: [:link, :unlink]

  def link
    user = User.find_by(id: params[:user_id])

    if !user.nil?
      consumer = Dropbox::API::OAuth.consumer(:authorize)
      request_token = consumer.get_request_token
      session[:token] = request_token.token
      session[:token_secret] = request_token.secret
      url = request_token.authorize_url(:oauth_callback => "#{dropbox_callback_url}?user_id=#{user.id}")
      redirect_to url
    else
      flash[:danger] = "Invalid User ID #{params[:user_id]}"
      redirect_to home_path
    end
  end

  def unlink
    user = User.find_by(id: params[:user_id])

    if !user.nil?
      user.dropbox_uid = nil
      user.dropbox_token = nil
      user.dropbox_secret = nil
      if user.save
        flash[:success] = "Unlinked from Dropbox"
      else
        flash[:danger] = "Could not Unlink from Dropbox"
      end
      redirect_to accounts_user_path(user)
    else
      flash[:danger] = "Invalid User ID #{params[:user_id]}"
      redirect_to home_path
    end
  end

  def callback
    user = User.find_by(id: params[:user_id])

    if !user.nil?
      consumer = Dropbox::API::OAuth.consumer(:authorize)
      hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret] }
      request_token = OAuth::RequestToken.from_hash(consumer, hash)
      oauth_verifier = params[:oauth_verifier]
      begin
        result = request_token.get_access_token(:oauth_verifier => oauth_verifier)
        user.dropbox_token = result.token
        user.dropbox_secret = result.secret
        user.dropbox_uid = params[:uid]
        client = Dropbox::API::Client.new(token: user.dropbox_token, secret: user.dropbox_secret)
        if !client.nil? and user.save
          flash[:success] = "Linked to Dropbox"
        else
          flash[:danger] = "Could not Link to Dropbox"
        end
      rescue OAuth::Unauthorized => e
        flash[:danger] = "Could not Link to Dropbox: #{e.message}"
      end
      redirect_to accounts_user_path(user)
    else
      flash[:danger] = "Invalid User ID #{params[:user_id]}"
      redirect_to root_url
    end
  end


  private

  def allowed_user
    @user = User.find_by id:params[:user_id]

    unless (current_user?(@user) or current_user.superuser?)
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
    end
  end
end
