class UsersController < ApplicationController
  acts_as_token_authentication_handler_for User
  before_action :set_user, only: [:show]
  before_action do
    head :forbidden unless current_user.is_admin?
  end
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

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

  def create
    params.require(:screen_name)
    params.require(:email)
    u = User.find_or_initialize_by(email: params[:email].gsub(/^U/, 'u'))
    u.screen_name = params[:screen_name]
    u.save!
    render json: { authentication_token: u.authentication_token }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
