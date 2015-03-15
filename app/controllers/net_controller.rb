class NetController < ApplicationController
  require 'uri'
  require "addressable/uri"

  @@header_store = {}
  @@cookie_store = {}

  def initialize
    puts "@net controller created"
  end

  #######
  #Возвращает значение определенной куки
  #######
  def getCookie(key)
    return @@cookie_store[key]
  end

  #######
  #Добавляет в массив куки, на вход следуюет подавать {key => name}
  #######
  def addCookie(cookie_data)
    tmp_cookie = @@cookie_store.merge(cookie_data)
    @@cookie_store = tmp_cookie
  end

  #######
  #Добавляет в массив заголовки, на вход следуюет подавать {key => name}
  #######
  def addHeader(header_data)
    tmp_header = @@header_store.merge(header_data)
    @@header_store = tmp_header
  end

  #######
  #Выполняет запрос POST или GET
  #######
  def httpRequest(request_method, request_url, request_data = {})
    uri = Addressable::URI.parse(request_url)
    ca_file = File.join(File.dirname(File.expand_path("../", __FILE__)), 'assets', 'cert', 'ca-bundle.crt')

    conn = Faraday.new(:url => "#{uri.scheme}://#{uri.host}", :ssl => {:ca_file => ca_file}) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    if @@cookie_store != {}
      @@header_store = @@header_store.merge({"Cookie" => hash_to_query(@@cookie_store, false).gsub('&', '; ')})
    end

    if request_method == "POST"
      request = conn.post do |req|
        req.url uri.path
        req.headers = @@header_store
        req.body = hash_to_query(request_data, true)
      end
    else
      request = conn.get(uri.path, request_data)
    end

    set_cookie = request.headers['set-cookie']

    if set_cookie != nil
      parsed_cookies = set_cookie.scan(/(.*?)=(.*?);(.*?)\s*path=\/\s*[secure;\s]*[httponly\,\s]*/)

      #Распарсенные куки добавляем в @@http_cookie
      parsed_cookies.each do |cookie|
        addCookie({cookie[0] => cookie[1]})
      end
    end

    puts request.body

    return request.body
  end

  #######
  #Преобразовывает hash массив в строку, есть параметр is_escape, который позволяет кодировать
  #######
  def hash_to_query(hash, is_escape)
    if is_escape == true
      return hash.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")
    else
      return hash.map{|k,v| "#{k}=#{v}"}.join("&")
    end
  end

end
