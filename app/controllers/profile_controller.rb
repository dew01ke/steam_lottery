class ProfileController < ApplicationController

  def index
    #soon coming
  end

  def addFunds
    #soon coming
  end

  def lastOperations
    a=Operation.where("user_steamid" => session[:steam_id])
  end

  def cashOut
    #soon coming
    won_items = PendingItem.where(:user_id => session[:steam_id])

    @available_items = []

    won_items.each do |item|
      @available_items.push({'id' => item.item_steam_id})
    end
  end

  def update
    if (session[:steam_id].nil? == false)
      updateUserInfo(session[:steam_id])
    end
    redirect_to '/'
  end

  def updateUserInfo(steam64)
    user_info = $papi.getUserInfo(session[:steam_id], APP_CONFIG['api_key'])
    #Файл, в котором хранится аватарка
    path_to_avatar = File.join(File.dirname(File.expand_path("../", __FILE__)), 'assets', 'images', 'avatars', session[:steam_id] + ".jpg")
    #Загружаем аватарку в память
    resource_avatar = $http.httpRequest("GET", user_info[0]['avatarfull'])
    #Сохраняем на диск
    File.open(path_to_avatar, 'wb') { |fp| fp.write(resource_avatar) }
  end
end