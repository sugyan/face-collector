class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # need login or token authentication
  acts_as_token_authentication_handler_for User
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  rescue_from ActiveRecord::RecordNotFound do |exception|
    logger.warn(exception)
    render file: Rails.root.join('public/404.html'), status: 404, layout: false
  end

  def after_sign_in_path_for(_)
    root_path
  end

  def after_sign_out_path_for(_)
    root_path
  end
end
