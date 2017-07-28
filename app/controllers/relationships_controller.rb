class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :find_user, only: :index

  attr_reader :user

  def index
    render_not_found unless user
    type = params[:type]
    @users = user.send(type).paginate page: params[:page]
  end

  def create
    active_relationships = current_user.active_relationships
    @user = User.find_by id: params[:followed_id]
    current_user.follow user
    @relationship_destroy = active_relationships.find_by followed_id: user.id
    handle_ajax
  end

  def destroy
    active_relationships = current_user.active_relationships
    @user = Relationship.find_by(id: params[:id]).followed
    current_user.unfollow user
    @relationship_build = active_relationships.build
    handle_ajax
  end

  private

  def find_user
    @user = User.find_by id: params[:user_id]
  end

  def handle_ajax
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end
end
