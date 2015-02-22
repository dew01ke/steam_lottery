class HttpController < ApplicationController
  require 'net/http'
  require 'net/https'
  require 'openssl'

  def index
    @auth = httpRequest("https://steamcommunity.com/login/getrsakey/", {'username' => 'dew01ke'})
  end

  #Отправляем Post запрос, на вход адрес и параметры запроса
  def httpRequest(request_url, request_data = {})
    req_url = URI.parse(request_url)

    http = Net::HTTP.new(req_url.host, req_url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = "C:\\Users\\Andrew\\RubymineProjects\\steam_lottery\\app\\assets\\cert\\ca-bundle.crt"

    resp = http.post(req_url.path, request_data.to_query, nil)

    return resp.body
  end

  def setCookies()
    #something
  end
end
