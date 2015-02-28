class PapiController < ApplicationController
  require 'net/http'
  require 'net/https'

  @@http = HttpController.new

  def id64
    @id = getSteam64(params[:steamlogin], params[:api_key])
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

  #returns steam64
  def getSteam64(steamlogin, api_key)
    url="http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/"
    data = {'key'=> api_key, 'vanityurl' => steamlogin}
    response = JSON.parse(@@http.httpRequest("GET", url, data))
    return response['response']['steamid']
  end

  #возвращает массив JSONов с данными о вещах
  def getBackpackByAppid(steamid64, api_key, appid)
    url = 'http://api.steampowered.com/IEconItems_570/GetPlayerItems/v0001/'
    data = {'key'=> api_key, 'SteamID' => steamid64}
    response = JSON.parse(@@http.httpRequest("GET", url, data))
    return response['result']['items']
  end

  def getBackpackLogin(steamlogin, appid)
    url = 'http://steamcommunity.com/id/' + steamlogin.to_s + '/inventory/json/' + appid.to_s + '/2/'
    response = JSON.parse(@@http.httpRequest("GET", url, {}))
    return response['rgInventory']
  end

  def getBackpack(steamid64, appid)
    url = 'http://steamcommunity.com/profiles/' + steamid64.to_s + '/inventory/json/' + appid.to_s + '/2/'
    response = JSON.parse(@@http.httpRequest("GET", url, {}))
    return response['rgInventory']
  end

  def getUserInfo(steamid64, api_key)
    url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/"
    data = {'key'=> api_key, 'steamids' => steamid64}
    response = JSON.parse(@@http.httpRequest("GET", url, data))
    return response['response']['players']
  end

  def getPricesByHashname(appid, market_hash_name)
    url = "http://steamcommunity.com/market/priceoverview/"
    data = {'country' => "ru", 'currency' => 1, 'appid' => appid, 'market_hash_name' => market_hash_name}
    response = JSON.parse(@@http.httpRequest("GET", url, data))
    return response
  end

  def getAssetPrices(api_key, appid)
    url = "http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/"
    data = {'key'=> api_key, 'appid' => appid}
    response = JSON.parse(@@http.httpRequest("GET", url, data))
    return response
  end
end
