class StaticPagesController < ApplicationController
  skip_before_filter :require_login

  def help
  end

  def about
  end

  def terms
  end

  def forgot_password
  end

  def verify_registration
  end
end
