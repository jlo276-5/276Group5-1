# http://blog.teamtreehouse.com/static-pages-ruby-rails
class HelpController < ApplicationController
  skip_before_filter :require_login, only: [:index, :about, :faq, :terms, :contact, :submit_contact]
  layout 'help_layout', except: [:index]

  def index
  end

  def show
    if valid_page?
      if !current_user.admin? && (params[:page].downcase == 'admin' || params[:page].downcase == 'institutions')
        flash[:danger] = "You do not have the permission to see that."
        redirect_to help_path
      else
        render template: "help/#{params[:page]}"
      end
    else
      # raise ActionController::RoutingError.new('Not Found')
      flash[:danger] = "No Such Help Page Found"
      redirect_to help_path
    end
  end

  def about
  end

  def faq
  end

  def terms
  end

  def contact
  end

  def submit_contact
  end

  private

  def valid_page?
    File.exist?(Pathname.new(Rails.root + "app/views/help/#{params[:page]}.html.md")) || File.exist?(Pathname.new(Rails.root + "app/views/help/#{params[:page]}.html.erb"))
  end

end
