class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout "application"
  protect_from_forgery with: :exception

  def index
    if session[:is_logged] != nil
      @user_steamlogin = session[:steam_login]
      @user_avatarurl = session[:avatar_url]
      @user_coincount = "0"
    end
  end
end
