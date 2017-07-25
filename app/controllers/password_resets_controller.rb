class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)

  attr_reader :user

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if user
      handle_valid_password_create
    else
      handle_invalid_password_create
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      handle_password_update_blank
    elsif user.update_attributes user_params
      handle_valild_password_update
    else
      render :edit
    end
  end

  private

  def handle_invalid_password_create
    flash.now[:danger] = t ".create.email_not_found"
    render :new
  end

  def handle_valid_password_create
    user.create_reset_digest
    user.send_password_reset_email
    flash[:info] = t ".create.instructions"
    redirect_to root_url
  end

  def handle_password_update_blank
    user.errors.add :password, t(".cant_be_empty")
    render :edit
  end

  def handle_valild_password_update
    user.update_attributes reset_digest: nil
    log_in user
    flash[:success] = t ".password_has_been_reset"
    redirect_to user
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    unless user && user.activated? && user.authenticated?(:reset,
      params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    return unless user.password_reset_expired?
    flash[:danger] = t ".check_expiration.password_expired"
    redirect_to new_password_reset_url
  end
end
