class CasAuthController < ApplicationController
  skip_before_filter :require_login
  require 'rest-client'

  def auth
    institution = Institution.find_by(id: params[:cas_auth][:institution_id])

    if !institution.nil?
      if institution.uses_cas
        cas_url = institution.cas_endpoint
        if cas_url.blank?
          flash[:danger] = "This Institution does not properly support CAS authentication."
          redirect_to login_path
        else
          callback_url = CGI::escape("#{cas_callback_url}?institution_id=#{institution.id}")
          cas_login_url = "#{cas_url}/login?service=#{callback_url}&app=StuHub"
          redirect_to cas_login_url
        end
      else
        flash[:warning] = "StuHub does not support CAS authentication for this Institution."
        redirect_to login_path
      end
    else
      flash[:danger] = "Invalid Institution ID #{params[:cas_auth][:institution_id]}"
      redirect_to login_path
    end
  end

  def callback
    institution = Institution.find_by(id: params[:institution_id])

    if !institution.nil?
      if institution.uses_cas
        cas_url = institution.cas_endpoint
        if cas_url.blank?
          flash[:danger] = "This Institution does not properly support CAS authentication."
          redirect_to login_path
        else
          callback_url = CGI::escape("#{cas_callback_url}?institution_id=#{institution.id}")
          validate = RestClient.get "#{cas_url}/serviceValidate?service=#{callback_url}&ticket=#{params[:ticket]}&app=StuHUb"
          data = Hash.from_xml(validate)
          if data["serviceResponse"]["authenticationFailure"].nil?
            authSuccess = data["serviceResponse"]["authenticationSuccess"]

            user_token = authSuccess["user"]
            user = User.find_by(cas_identifier: user_token)
            if user
              if user.activated?
                user.cas_login_active = true
                log_in(user)
                flash[:success] = "Successfully logged in via #{institution.name} CAS."
                redirect_back_or home_url
              else
                flash[:warning] = "This account is not activated. Please check your email for the activation link."
                redirect_to login_url
              end
            else
              flash[:warning] = 'Please create an account on StuHub.'
              redirect_to register_path(institution_id: institution.id, cas_identifier: user_token)
            end
          else
            flash[:danger] = "CAS authentication did not work. Please sign in manually or try again."
            redirect_to login_path
          end
        end
      else
        flash[:warning] = "StuHub does not support CAS authentication for this Institution."
        redirect_to login_path
      end
    else
      flash[:danger] = "Invalid Institution ID #{params[:institution_id]}"
      redirect_to login_path
    end
  end
end
