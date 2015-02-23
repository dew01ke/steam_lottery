class HttpController < ApplicationController
  require 'net/http'
  require 'net/https'
  require 'openssl'

  @@http_cookie = {}
  @@http_header = {}

  def index
    setHeader({'User-Agent' => 'Lottery Offer Bot'})
    @auth = httpRequest("GET", "http://api.steampowered.com/ISteamEconomy/GetAssetPrices/v0001/", {"appid"=>"570", "key"=>"40203AB5100825DF97F990FCE10E7916"})
  end

  #######
  #Отправляем Post запрос, на вход адрес и параметры запроса
  #######
  def httpRequest(request_method, request_url, request_data = {} )

    req_url = URI.parse(request_url)

    if request_method == "GET"
      req_url.query = URI.encode_www_form(request_data)
      http = Net::HTTP.new(req_url.host, req_url.port)
    else
      http = Net::HTTP.new(req_url.host, req_url.port)
    end

    if req_url.scheme == 'https'
      http.use_ssl = true
      http.ca_file = File.join(File.dirname(File.expand_path("../", __FILE__)), 'assets', 'cert', 'ca-bundle.crt')
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    if @@http_cookie != {}
      @@http_header = @@http_header.merge({"Cookie" => (@@http_cookie.to_query).gsub('&', '; ')})
    end

    if request_method == "GET"
      resp = http.request(Net::HTTP::Get.new(req_url.request_uri))
    else
      resp = http.post(req_url.path, request_data.to_query, @@http_header)
    end

    case resp
      when Net::HTTPSuccess
        return resp.body
      else
        return -1
    end
  end

  #######
  #Добавляем информацию в Cookies
  #######
  def setCookie(cookie_data)
    tmp_cookie = @@http_cookie.merge(cookie_data)
    @@http_cookie = tmp_cookie
  end

  #######
  #Добавляем информацию в заголовок
  #######
  def setHeader(header_data)
    tmp_header = @@http_header.merge(header_data)
    @@http_header = tmp_header
  end

end
