class UsersController < ApplicationController
  attr_reader :user
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if user.save
      flash[:success] = t "welcome_to_app"
      redirect_to user
    else
      render :new
    end
  end

  def show
    @user = user = User.find_by id: params[:id]

    return if user
    flash[:danger] = t "not_exist_user"
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end
