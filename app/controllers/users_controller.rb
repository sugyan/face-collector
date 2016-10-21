class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :authenticate_user!

  def index
    @users = User.order(:id)
  end

  def show
    @faces = @user.faces
      .includes(:label, :photo)
      .order(updated_at: :desc)
      .page(params[:page])
      .per(50)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
