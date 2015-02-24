class AuthController < ApplicationController

  require 'json'
  require 'openssl'
  require 'base64'

  @@http = HttpController.new
  @@steam_rsa_url = "https://steamcommunity.com/login/getrsakey/"
  @@steam_auth_url = "https://steamcommunity.com/login/dologin/"

  def index
    steamLogin("dew01ke", "***")
  end

  #######
  #Авторизация на портале steamcommunity.com, возвращается 3 токена
  #######
  def steamLogin(bot_username, bot_password)

    #Формируем данные для получения Экспоненты и Модуля
    rsa_post_data = {"username" => bot_username, "donotcache" => getTimestamp}
    #Отправляем Post запрос
    response = @@http.httpRequest("POST", @@steam_rsa_url, rsa_post_data)
    #Парсим полученный Json массив
    rsa_response_data = JSON.parse(response)

    #Извлекаем Экспоненту и Модуль и переводим из 16 СИ в 10-ую
    rsa_modulus = rsa_response_data['publickey_mod'].hex
    rsa_exponent = rsa_response_data['publickey_exp'].hex

    #На основе Экспоненты и Модуля создаем публичный ключ RSA
    sequence = OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::Integer.new(rsa_modulus), OpenSSL::ASN1::Integer.new(rsa_exponent)])
    public_key = OpenSSL::PKey::RSA.new(sequence.to_der)

    #Шифруем публичным ключом пароль и кодируем в Base64
    @rsa_encrypted_password = Base64.strict_encode64(public_key.public_encrypt(bot_password))

    #Заносим данные для доступа во вьюшке
    @rsa_timestamp = rsa_response_data['timestamp']
    @username = bot_username
    @donotcache = getTimestamp

    #Формируем данные для авторизации
    auth_post_data = {"password" => @rsa_encrypted_password,
                      "username" => @username,
                      "rsatimestamp" => @rsa_timestamp,
                      "remember_login" => false,
                      "donotcache" => @donotcache}

    #Отправляем Post запрос
    response = @@http.httpRequest("POST", @@steam_auth_url, auth_post_data)
    #Парсим полученный Json массив
    auth_response_data = JSON.parse(response)

    #DEBUG
    puts response

    #Нужно подтверждение по электропочте
    if auth_response_data["emailauth_needed"] == true
      @CAPTCHA_GID = ""
      @CAPTCHA_IMG = ""
      @EMAIL_ID = auth_response_data["emailsteamid"]
      @POST_DATA = auth_post_data
    end

    #Нужно ввести капчу
    if auth_response_data["captcha_needed"] == true
      @EMAIL_ID = ""
      @CAPTCHA_GID = auth_response_data['captcha_gid']
      @CAPTCHA_IMG = "<img src='https://steamcommunity.com/public/captcha.php?gid=#{auth_response_data['captcha_gid']}'>"
      @OTHER_URL = auth_post_data
    end

    #Если авторизовались
    if auth_response_data["success"] == true
      @token = auth_response_data["transfer_parameters"]["token"]
    end
  end

  #######
  #Возвращает Unix Timestamp
  #######
  def getTimestamp
    return Time.now.to_i
  end

  #######
  #Доотправляет данные если нужно ввести капчу или код почты
  #######
  def resend
    #Отправляем запрос с добавленными данными
    response = @@http.httpRequest("POST", @@steam_auth_url, {'password' => params[:password],
                                                             'username' => params[:username],
                                                             'rsatimestamp' => params[:rsatimestamp],
                                                             'donotcache' => params[:donotcache],
                                                             'emailsteamid' => params[:emailsteamid],
                                                             'emailauth' => params[:emailauth],
                                                             'captcha_gid' => params[:captcha_gid],
                                                             'captcha_text' => params[:captcha_text]})

    #Парсим полученный Json массив
    auth_response_data = JSON.parse(response)

    #Если авторизовались
    if auth_response_data["success"] == true
      @token = auth_response_data["transfer_parameters"]["token"]
    end
  end
end
