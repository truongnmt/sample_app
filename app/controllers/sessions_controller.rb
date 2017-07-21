class SessionsController < ApplicationController
  def new; end

  def create
    session = params[:session]
    user = User.find_by email: session[:email].downcase
    if user && user.authenticate(session[:password])
      handle_valid_login user, session
    else
      handle_invalid_login
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def handle_valid_login user, session
    if user.activated?
      handle_activated_user user, session
    else
      handle_unactivated_user
    end
  end

  def handle_activated_user user, session
    log_in user
    session[:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def handle_unactivated_user
    message = t ".create.check_email"
    flash[:warning] = message
    redirect_to root_url
  end

  def handle_invalid_login
    flash.now[:danger] = t "error_login_message"
    render :new
  end
end
