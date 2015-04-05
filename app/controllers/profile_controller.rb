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
    won_items = PendingItem.joins(:price).where(:user_id => session[:steam_id])

    @available_items = []

    won_items.each do |item|
      hashed_image_url = item.price.image_url
      if not hashed_image_url.nil?
        @available_items.push({'id' => item.item_steam_id, 'image_url' => item.price.image_url})
      else
        @available_items.push({'id' => item.item_steam_id, 'image_url' => "../empty_small.jpg"})
      end
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

  def setUpTradeOfferLink()
    trade_url = params[:tourl]
    parsed_url = trade_url.match(/[http|https]+:\/\/steamcommunity.com\/tradeoffer\/new\/\?partner=([\d]{8})&token=(.*)/)

    puts trade_url

    if not parsed_url.nil?
      #Стим32 с ссылки
      url_steam32 = parsed_url[1].to_i
      #Токен с ссылки
      url_token = parsed_url[2]
      #Считаем оригинальный стим32
      original_steam32 = (session[:steam_id].to_i - 76561197960265728)

      #Если оригинальный стим 32 совпадает с ссылочным
      if url_steam32 == original_steam32

        #Обновляем бд, новым токеном
        user = User.find_by(steam64: session[:steam_id])
        user.last_to_token = url_token
        session[:last_to_token] = url_token
        user.save

        @a = {'success' => true, 'message' => ''}.to_json
        render :json => @a
      else
        puts "not your"

        @a = {'success' => false, 'message' => 'this link not your'}.to_json
        render :json => @a
      end

    else
      puts "error: empty"

      @a = {'success' => false, 'message' => 'not valid trade url'}.to_json
      render :json => @a
    end


  end
end