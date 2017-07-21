class AccountActivationsController < ApplicationController
  before_action :find_user, only: :edit

  attr_reader :user

  def edit
    if user && !user.activated? && user.authenticated?(:activation,
      params[:id])
      handle_valid_activation
    else
      handle_invalid_activation
    end
  end

  private

  def find_user
    @user = User.find_by email: params[:email]

    return if user
    flash[:danger] = t "not_exist_user"
    redirect_to root_path
  end

  def handle_valid_activation
    user.activate
    log_in user
    flash[:success] = t "sessions.edit.account_activated"
    redirect_to user
  end

  def handle_invalid_activation
    flash[:danger] = t "sessions.edit.invalid_activation_link"
    redirect_to root_url
  end
end
