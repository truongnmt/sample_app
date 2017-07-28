class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "users.please_log_in"
    redirect_to login_url
  end

  def render_not_found
    render file: Rails.root.join("public", "404.html"),
      status: 404
  end
end
