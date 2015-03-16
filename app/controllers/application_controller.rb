class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout "application"
  protect_from_forgery with: :exception

  def index
    puts "Application started"

    $http = NetController.new
    $papi = PapiController.new

    @user_steamlogin = "dew01ke"
    @user_avatarurl = "/dsd"
    @user_coincount = "1488"
  end
end
