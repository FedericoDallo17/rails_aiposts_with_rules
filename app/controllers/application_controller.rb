class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :first_name, :last_name, :bio, :website, :location ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :first_name, :last_name, :bio, :website, :location, :profile_picture, :cover_picture ])
  end
end
