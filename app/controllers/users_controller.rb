class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  before_action :authenticate_user!
  before_action do
    redirect_to root_path unless current_user.is_admin?
  end

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
