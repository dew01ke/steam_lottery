class HttpController < ApplicationController
  require 'net/http'
  require 'net/https'
  require 'openssl'

  @@http_cookie = {}
  @@http_header = {}

  def initialize
    puts "class Http created"
    setHeader({'User-Agent' => 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.122 YaBrowser/14.12.2125.10034 Safari/537.36'})
  end

  #######
  #Отправляем Post запрос, на вход адрес и параметры запроса
  #######
  def httpRequest(request_method, request_url, request_data = {} )
    #Парсим наш адрес на компоненты протокол://хост/запрос
    req_url = URI.parse(request_url)

    #Создаем запрос в зависимости от POST или GET
    if request_method == "GET"
      req_url.query = URI.encode_www_form(request_data)
      http = Net::HTTP.new(req_url.host, req_url.port)
    else
      http = Net::HTTP.new(req_url.host, req_url.port)
    end

    #Если используется протокол HTTPS, то подключаем локальный сертификат
    if req_url.scheme == 'https'
      http.use_ssl = true
      http.ca_file = File.join(File.dirname(File.expand_path("../", __FILE__)), 'assets', 'cert', 'ca-bundle.crt')
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    #Если массив с куками пуст, то не прикрепляем их к нашему заголовку
    if @@http_cookie != {}
      @@http_header = @@http_header.merge({"Cookie" => buildCookie})
    end

    #Посылаем запрос на нужный адрес в зависимости от POST или GET
    if request_method == "GET"
      resp = http.request(Net::HTTP::Get.new(req_url.request_uri))
    else
      resp = http.post(req_url.path, request_data.to_query, @@http_header)
    end

    #Если сервер присылаем нам свои куки для установки, забираем их
    set_cookie = resp.response['set-cookie']
    #Парсим их, чтобы был вид key=value
    if set_cookie != nil
      parsed_cookies = set_cookie.scan(/(.*?)=(.*?);(.*?)\s*path=\/[,\s]*/)

      #Распарсенные куки добавляем в @@http_cookie
      parsed_cookies.each do |cookie|
        setCookie({cookie[0] => cookie[1]})
      end
    end

    #Смотрим какой код ответа нам вернул сервер, если все ОК, то ретурним
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
