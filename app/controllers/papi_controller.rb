class PapiController < ApplicationController
  require 'net/http'
  require 'net/https'

  def initialize
    puts ">>Papi controller created"
  end

  def id64
    @id = getSteam64(nil, params[:api_key])
  end

  def backpackAppid
    @result = getBackpackByAppid(params[:steamid64], params[:api_key], params[:appid])
  end

  def backpackLogin
    @result = getBackpackLogin(params[:steamlogin], params[:appid])
  end

  def backpack
    @result = getBackpack(params[:steamid64], params[:appid])
  end

  def userinfo
    @result = getUserInfo(params[:steamid64], params[:api_key])
  end

  def pricebyhash
    @result = getPricesByHashname(params[:appid], params[:market_hash_name])
  end

  def asset
    @result = getAssetPrices(params[:api_key], params[:appid])
  end

  def cancelTradeOffer(api_key, tradeofferid)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = "http://api.steampowered.com/IEconService/CancelTradeOffer/v1/"
      data = {"key" => api_key, "tradeofferid" => tradeofferid}

      Thread.current["request"] = Thread.current["local_http"].httpRequest("POST", url, data)
    end
    http.join

    response = JSON.parse(http["request"])

    if (http["request"] != -1) and (response != nil)
      return 1
    else
      return -1
    end
  end

  def getHistoricalTradeOffers(api_key)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = "http://api.steampowered.com/IEconService/GetTradeOffers/v1/"

      flags = {"get_sent_offers" => "true", "historical_only" => "true"}
      data = {"key" => api_key, "format" => "json", "input_json" => flags.to_json}

      Thread.current["request"] = Thread.current["local_http"].httpRequest("GET", url, data)
    end
    http.join

    if (http["request"] != -1)
      response = JSON.parse(http["request"])
      return response['response']['trade_offers_sent']
    else
      return -1
    end
  end

  #returns steam64
  def getSteam64(steamlogin, api_key)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = "http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/"

      data = {'key' => api_key, 'vanityurl' => steamlogin}

      Thread.current["request"] = Thread.current["local_http"].httpRequest("GET", url, data)
    end
    http.join

    if (http["request"] != -1)
      response = JSON.parse(http["request"])
      if (response['response']['success'].to_i == 1)
      return response['response']['steamid']
      else
        return -1
      end
    else
      return -1
    end
  end

  def getBackpackLogin(steamlogin, appid)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = 'http://steamcommunity.com/id/' + steamlogin.to_s + '/inventory/json/' + appid.to_s + '/2/'

      Thread.current["request"] = Thread.current["local_http"].httpRequest("GET", url, {'l' => 'russian'})
    end
    http.join

    if (http["request"] != -1)
      response = JSON.parse(http["request"])
      if (response['success'].to_s == 'false')
        return -1
      else
        return response
      end
    else
      return -1
    end
  end

  def getBackpack(steamid64, appid)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = 'http://steamcommunity.com/profiles/' + steamid64.to_s + '/inventory/json/' + appid.to_s + '/2'

      Thread.current["request"] = Thread.current["local_http"].httpRequest("GET", url, {'l' => 'russian'})
    end
    http.join

    if (http["request"] != -1)
      response = JSON.parse(http["request"])
      if (response['success'].to_s == 'false')
        return -1
      else
        return response
      end
    else
      return -1
    end
  end

  def getUserInfo(steamid64, api_key)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/"

      data = {'key' => api_key, 'steamids' => steamid64}


      Thread.current["response"] = JSON.parse(Thread.current["local_http"].httpRequest("GET", url, data))
    end
    http.join

    return http['response']['response']['players']
    #in case of wrong id, response['response']['players'] is empty
  end

  def getPricesByHashname(appid, market_hash_name)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = "http://steamcommunity.com/market/priceoverview/"

      data = {'country' => "ru", 'currency' => 1, 'appid' => appid, 'market_hash_name' => market_hash_name}

      Thread.current["request"] = Thread.current["local_http"].httpRequest("GET", url, data)
    end
    http.join

    if (http["request"] != -1)
      response = JSON.parse(http["request"])
      return response
    else
      return -1
    end
    #no HTTP errors, response contains {"success":false} if wrong data is provided
  end

  def getAssetPrices(api_key, appid)
    http = Thread.new do
      #Создаем контроллер
      Thread.current["local_http"] = NetController.new

      url = "http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/"

      data = {'key'=> api_key, 'appid' => appid}

      Thread.current["request"] = Thread.current["local_http"].httpRequest("GET", url, data)
    end
    http.join

    if (http["request"] != -1)
      response = JSON.parse(http["request"])
      if (response['result']['success'].to_s == 'false')
        return -1
      else
        return response['result']['assets']
      end
    else
      return -1
    end
  end
end
