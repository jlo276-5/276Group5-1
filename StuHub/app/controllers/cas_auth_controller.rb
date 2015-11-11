class CasAuthController < ApplicationController
  skip_before_filter :require_login, only: [:auth, :callback]
  require 'rest-client'

  def enable
    user = User.find_by(id: params[:user_id])

    if !user.nil?
      if user.cas_identifier.blank?
        if !user.institution.nil?
          if user.institution.uses_cas
            cas_url = user.institution.cas_endpoint
            if cas_url.blank?
              flash[:danger] = "This Institution does not properly support CAS authentication."
              redirect_to accounts_user_path(user)
            else
              callback_url = CGI::escape("#{cas_callback_url}?institution_id=#{user.institution.id}&user_id=#{user.id}")
              cas_login_url = "#{cas_url}/login?service=#{callback_url}&app=StuHub"
              redirect_to cas_login_url
            end
          else
            flash[:warning] = "StuHub does not support CAS authentication for this Institution."
            redirect_to accounts_user_path(user)
          end
        else
          flash[:danger] = "Invalid Institution ID #{user.institution_id}"
          redirect_to accounts_user_path(user)
        end
      else
        flash[:warning] = "This user already has CAS Authentication enabled."
        redirect_to accounts_user_path(user)
      end
    else
      flash[:danger] = "Invalid User ID #{params[:user_id]}"
      redirect_to home_path
    end
  end

  def disable
    user = User.find_by(id: params[:user_id])

    if !user.nil?
      if !user.cas_identifier.blank?
        user.cas_identifier = nil
        user.cas_login_active = false
        user.save
        flash[:success] = "CAS Authentication disabled for this User."
      else
        flash[:warning] = "This user already has CAS Authentication disabled."
      end
      redirect_to accounts_user_path(user)
    else
      flash[:danger] = "Invalid User ID #{params[:user_id]}"
      redirect_to home_path
    end
  end

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
          callback_url = CGI::escape("#{cas_callback_url}?institution_id=#{institution.id}#{params[:user_id].blank? ? "" : "&user_id=#{params[:user_id]}"}")
          validate = RestClient.get "#{cas_url}/serviceValidate?service=#{callback_url}&ticket=#{params[:ticket]}&app=StuHUb"
          data = Hash.from_xml(validate)
          if data["serviceResponse"]["authenticationFailure"].nil?
            authSuccess = data["serviceResponse"]["authenticationSuccess"]

            user_token = authSuccess["user"]
            if !params[:user_id].blank?
              user = User.find_by(id: params[:user_id])
              if user
                user.cas_identifier = user_token
                user.cas_login_active = true
                user.save
                flash[:success] = "CAS Authentication enabled for this User."
                redirect_to accounts_user_path(user)
              else
                flash[:warning] = "Invalid User ID #{params[:user_id]}"
                redirect_to register_path(institution_id: institution.id, cas_identifier: user_token)
              end
            else
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
