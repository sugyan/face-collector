class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def default_url_options
    if Rails.env.production?
      super.merge(host: ENV['DOMAIN_NAME'], port: nil)
    else
      {}
    end
  end

  def after_sign_in_path_for(_)
    collector_path
  end

  def after_sign_out_path_for(_)
    collector_path
  end
end
