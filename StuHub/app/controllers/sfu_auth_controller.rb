class SfuAuthController < ApplicationController
  skip_before_filter :require_login
  require 'rest-client'

  @SFU_CAS_BASE = "https://cas.sfu.ca/cas/"

  def auth
  end

  def callback
    puts params[:ticket]

    response = RestClient.get "https://cas.sfu.ca/cas/serviceValidate?service=http://localhost:3000/sfu_callback&ticket=#{params[:ticket]}"
    data = Hash.from_xml(response)
    if data["serviceResponse"]["authenticationFailure"].nil?
      if data["serviceResponse"]["authenticationSuccess"]["user"].nil?
        redirect_to sfu_success_path
      else
        redirect_to sfu_success_path(user: data["serviceResponse"]["authenticationSuccess"]["user"], authtype: data["serviceResponse"]["authenticationSuccess"]["authtype"])
      end
    else
      redirect_to sfu_failure_path
    end
  end

  def success
    if !params[:user].nil?
      @user = params[:user]
      @authtype = params[:authtype]
    end
  end

  def failure
  end
end
