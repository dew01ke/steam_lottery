class OpenidController < ApplicationController
  require "openid"
  require 'openid/extensions/sreg'
  require 'openid/extensions/pape'
  require 'openid/store/filesystem'

  layout nil

  def index
  end

  def auth(returned_url)
    #Получаем steamid64
    id = returned_url.match(/http[s]*:\/\/steamcommunity.com\/openid\/id\/([\d]+)/)[1]

    #Делаем запрос на получение данных
    user_info = $papi.getUserInfo(id, APP_CONFIG['api_key'])

    #Заносим пользователя в базу данных
    if User.exists?(steam64: id) == false
      user = User.new do |u|
        u.steam64 = id
        u.exp = 0
        u.points = 10000
        u.banned = 0
      end
      user.save
    end

    #Устанавливаем сессию
    session[:is_logged] = true
    session[:avatar_url] = user_info[0]['avatarfull']
    session[:steam_login] = user_info[0]['personaname']
    session[:coin_count] = (User.find_by steam64: id).points
    session[:steam_id] = id
  end

  def start
    begin
      identifier = APP_CONFIG['steam_openid']
      if identifier.nil?
        flash[:error] = "Enter an OpenID identifier"
        redirect_to :action => 'index'
        return
      end
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{identifier}: #{e}"
      redirect_to :action => 'index'
      return
    end
    return_to = url_for :action => 'complete', :controller => 'openid', :only_path => false
    realm = url_for :action => 'complete', :id => nil, :only_path => false

    if oidreq.send_redirect?(realm, return_to, params[:immediate])
      redirect_to oidreq.redirect_url(realm, return_to, params[:immediate])
    else
      render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
    end
  end

  def complete
    # FIXME - url_for some action is not necessarily the current URL.
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    parameters.reject!{|k,v|%w{action controller}.include? k.to_s}
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
      when OpenID::Consumer::FAILURE
        if oidresp.display_identifier
          flash[:error] = ("Verification of #{oidresp.display_identifier} failed: #{oidresp.message}")
        else
          flash[:error] = "Verification failed: #{oidresp.message}"
        end
      when OpenID::Consumer::SUCCESS
        auth(oidresp.display_identifier)
      when OpenID::Consumer::SETUP_NEEDED
        flash[:alert] = "Immediate request failed - Setup Needed"
      when OpenID::Consumer::CANCEL
        flash[:alert] = "OpenID transaction cancelled."
      else
    end
    redirect_to :action => 'index', :controller => 'application'
  end

  private

  def consumer
    if @consumer.nil?
      dir = Rails.root.join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end
end
