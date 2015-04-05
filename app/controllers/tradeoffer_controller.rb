class TradeofferController < ApplicationController
  #Запрещаем вывод в лайоут
  layout false

  def initialize
    puts ">>Trade controller created"
  end

  ######
  ######УДАЛИТЬ, ТОЛЬКО ДЛЯ ТЕСТА || ЗАПУСКАЕМ РАЗ В 30 СЕК
  ######
  def checkAcception
    puts "BEGIN checking acception"
    puts $ActiveTradeOffers

    $ActiveTradeOffers.each do |id, active_offers|
      #Смотрим, чтобы структура не равна {"1" => []}
      if $ActiveTradeOffers[id].any?
        #Извлекаем данные о текущем боте из БД
        this_bot = Bot.find(id)

        #Загружаем историю об завершенных офферах
        history = $papi.getHistoricalTradeOffers(this_bot.api_key)

        #Проверяем полученную историю
        history.each do |offer|

          #Если есть совпадение
          toid = $ActiveTradeOffers[id].index{ |active| active['tradeofferid'] == offer['tradeofferid'] }

          if (toid.nil? == false)
            #Статус трейдоффера из истории
            if offer["trade_offer_state"].to_i == 3
              puts "Tradeoffer accepted successfully. Adding points (" + $ActiveTradeOffers[id][toid]['coins'].to_s + ") to user with id=" + $ActiveTradeOffers[id][toid]['steam64'].to_s

              #Пополняем счет
              user = User.find_by(steam64: session[:steam_id])
              user.points = user.points + $ActiveTradeOffers[id][toid]['coins'].to_i
              session[:coin_count] = user.points
              user.save

              #Удаляем уведомление, если принято
              if session[:unique_id] == $ActiveTradeOffers[id][toid]['unique_id']
                puts "clear Notification by acception"
                clearNotification()
              end

              #Удаляем принятую
              $ActiveTradeOffers[id].delete_at(toid)
            else
              puts "Tradeoffer was declined by user"

              #Удаляем уведомление, если отклонено
              if session[:unique_id] == $ActiveTradeOffers[id][toid]['unique_id']
                puts "clear Notification by declining"
                clearNotification()
              end

              #Удаляем отмененную
              $ActiveTradeOffers[id].delete_at(toid)
            end
          end
        end

        #Получаем список протухших раздач
        expired = $ActiveTradeOffers[id].select {|value| ((Time.now - value["timestamp"].to_time) / 60).floor >= APP_CONFIG['tradeoffer_timeout']}
        expired.each_with_index do |e, i|
          if $papi.cancelTradeOffer(this_bot.api_key, e['tradeofferid']).to_i == 1
            puts "Trade offer #{e['tradeofferid']} canceled by System"

            #Удаляем уведомление, если прошел таймоут
            if session[:unique_id] == e['unique_id']
              puts "clear Notification"
              clearNotification()
            end

            #Удаляем
            $ActiveTradeOffers[id].delete_at(i)
          end
        end
      end
    end

    puts $ActiveTradeOffers
    puts "END checking acception"
  end

  ######
  ######УДАЛИТЬ, ТОЛЬКО ДЛЯ ТЕСТА
  ######
  def clearNotification()
    session.delete(:notification)
    session.delete(:unique_id)
    session.delete(:tradeofferid)
  end

  #Получение инвентаря пользователя
  def getInventory(steam64, appId)
    #Загружаем инвентарь
    inventory = $papi.getBackpack(steam64, appId)
    #Массив для вывода
    tmp = []

    inventory['rgInventory'].each do |item|
      current = inventory['rgDescriptions'][item[1]['classid'].to_s + '_' + item[1]['instanceid'].to_s]

      if current['tradable'] == 1

        show = true
        #фильтруем кейсы и музыку
        current['tags'].each do |t|
          if t['category']=="Type"
            type = t['internal_name'].split('_')
            type = type.last.downcase!
            if (type.eql?("weaponcase") or type.eql?("musickit"))
              #кейсы и музыку заныкать и никому не показывать
              show = false
            end
          end
        end

        #если вдруг шмотка оказалась не кейсом и не музыкой. придется ее показывать :(
        if show == true

        price_result = getItemPrice(appId, current['market_hash_name'].to_s)

        #если шмотка новая и нужно вписать название и качество
        if price_result['success'] == 2
          #кешируем пикчу
          key='key'
          digest = OpenSSL::Digest.new('sha1')
          filename = OpenSSL::HMAC.hexdigest(digest, key, current['market_hash_name'].to_s)
          resource_pic = $http.httpRequest("GET", "http://steamcommunity-a.akamaihd.net/economy/image/" + current['icon_url_large'])
          path_to_avatar = File.join(File.dirname(File.expand_path("../", __FILE__)), 'assets', 'images', 'items', filename + ".png")
          File.open(path_to_avatar, 'wb') { |fp| fp.write(resource_pic) }
          $prices[price_result['arrayid']]['image_url'] = filename + ".png"

          $prices[price_result['arrayid']]['display_name_rus'] = current['market_name']
          quality = ""
          current['tags'].each do |t|
            if t['category']=="Rarity"
              quality = t['internal_name'].split('_')
              if quality.size > 1
                quality = quality[1]
              else
                quality = quality[0]
              end
            end
          end
          quality.downcase!
          quality = $quality_color[appId.to_s].index{|x| x == quality}
          $prices[price_result['arrayid']]['quality'] = quality
          fetchprice = Price.find(price_result['arrayid'])
          fetchprice['quality'] = quality
          fetchprice['display_name_rus'] = current['market_name']
          fetchprice['image_url'] = filename + ".png"
          fetchprice.save
        end

        #если все норм, в т.ч. с ценой, отправляем шмотку на вывод
        if price_result['success'] > 0
          #Строка состоящая из assetid + market_hash_name + salt(time)
          item_identificator = "#{item[1]['id']}@@#{current['market_hash_name']}@@#{Time.now}"

          #Инициализируем алгоритм шифрования AES256 + ключ SHA256
          cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
          cipher.encrypt
          cipher.key = Digest::SHA256.digest(APP_CONFIG['secret_key'])
          cipher.iv = initialization_vector = cipher.random_iv
          encrypted = Base64.urlsafe_encode64(initialization_vector + cipher.update(item_identificator) + cipher.final)

          tmp.push({'title' => current['market_hash_name'].to_s, 'image_url' => current['icon_url_large'].to_s, 'price' => price_result['price'], 'param' => encrypted})
        end
        end
      end
    end

    return JSON.generate(tmp)
  end

  #Отправляем оффер для полнение депозита
  def sendTradeOffer()
    #Получаем шифрованный список вещей
    user_items = params[:myItems]
    user_appid = params[:appId]
    #Вещи, которые мы хотим забрать
    pick_items = []
    #Стоимость вводимых вещей
    items_cost = 0
    #Ид бота
    bot_id = 1

    #Составляем массив нужных вещей и считаем цену
    user_items.each do |item|
      #Снимаем со строки Base64
      deencrypted = Base64.urlsafe_decode64(item)

      #Инициализируем алгоритм AES256
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.decrypt
      cipher.key = Digest::SHA256.digest(APP_CONFIG['secret_key'])
      cipher.iv = deencrypted.slice!(0, 16)
      decrypted = cipher.update(deencrypted) + cipher.final

      #Извлекаем из строки assedid + market_hash_name
      splitted = decrypted.split('@@')

      #Извлекаем цену по item_hash_name
      items_cost += $prices.select{|n| not n.nil? and n['item_hash_name'] == splitted[1]}[0]['item_cost']

      #Добавляем в массив требуемых вещей
      pick_items.push({"appid" => user_appid, "contextid" => "2", "amount" => 1, "assetid" => splitted[0]})
    end

    tradeoffer_response = makeTradeOffer(bot_id, session[:steam_id], [], pick_items)

    puts tradeoffer_response

    #Если ответ вернулся нормальный, то
    if tradeoffer_response != -1
      #Парсим ответ
      response_data = JSON.parse(tradeoffer_response)

      if response_data["tradeofferid"].to_i > 0
        session[:notification] = true
        session[:unique_id] = @unique_id
        session[:tradeofferid] = response_data["tradeofferid"]

        #Добавляем на проверку принятия трейдоффера
        if $ActiveTradeOffers.exclude?(bot_id)
          $ActiveTradeOffers[bot_id] = []
        end
        $ActiveTradeOffers[bot_id].push({"tradeofferid" => response_data["tradeofferid"], "steam64" => session[:steam_id], "unique_id" => @unique_id, "timestamp" => "#{Time.now}",  "coins" => items_cost})

        #Вывод успешного результата
        @a = JSON.generate({"success" => true, "uid" => @unique_id, 'tid' => response_data["tradeofferid"]})
        render :json => @a
      else
        @a = JSON.generate({"success" => false})
        render :json => @a
      end
    else
      @a = JSON.generate({"success" => false})
      render :json => @a
    end
  end

  #Общая функция трейдофферов
  def makeTradeOffer(botId, themSteam64, myItems = [], themItems = [])
    #Уникальный токен для данного действия
    @unique_id = Digest::MD5.hexdigest(themSteam64 + Time.now.to_s)[4..8].upcase!

    #Выбираем бота
    bot = Bot.find(botId)

    #Заполняем куки
    $http.addCookie({
                        'sessionid' => bot.last_sessionid,
                        'steamLogin' => (bot.steam64.to_s + "%7C%7C" + bot.token),
                        'steamLoginSecure' => (bot.steam64.to_s + "%7C%7C" + bot.token_secure),
                        ('steamMachineAuth' + bot.steam64.to_s) => bot.webcookie
                    })

    #Заполняем заголовок
    $http.addHeader({
                        "User-Agent" => bot.user_agent,
                        "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
                        "Referer" => "https://steamcommunity.com/tradeoffer/new/?partner=" + (themSteam64.to_i - 76561197960265728).to_s
                    })
    #Заполняем сам запрос
    body = {
        "sessionid" => bot.last_sessionid,
        "serverid" => "1",
        "partner" => themSteam64.to_s,
        "tradeoffermessage" => ("Токен действия: #{@unique_id}"),
        "json_tradeoffer" => '{"newversion":true,"version":2,"me":{"assets":' + myItems.to_json + ',"currency":[],"ready":false},"them":{"assets":' + themItems.to_json + ',"currency":[],"ready":false}}',
        "captcha" => "",
        "trade_offer_create_params" => "{}"
    }

    #Посылаем запрос
    response = $http.httpRequest("POST", APP_CONFIG['steam_trade_url'], body)

    return response
  end

  #Коды для success
  #-1 - все плохо
  #1 - все отлично
  #2 - шмотки не было в БД, цену получили, но нужно будет дописать имя и качество
  def getItemPrice(appid,market_hash_name)
    #ищем шмотку в массиве
    a=$prices.find_index{|x| if (x.nil? ==false)
                               x['item_hash_name'] == market_hash_name
                             end}
    if (a.nil? == false)
      puts "Item found!"
      return {'success' => 1, 'price' => $prices[a]['item_cost']}
    else
      #шмотки нет в БД, писец, создаем
      puts "No item here, creating"
      c={}
      c['item_hash_name'] = market_hash_name
      c['appid'] = appid
      c['display_name_eng'] = market_hash_name
      c['display_name_rus'] = market_hash_name
      c['last_update'] = Time.new(2010,10,10)
      c['quality'] = 0
      c['item_cost'] = 0
      tmp=Price.create(c)
      tmp.save
      arrid = Price.where('item_hash_name' => market_hash_name).first['id']
      $prices[arrid] = c
      return {'success' => 2, 'price' => updateItemPrice(arrid)['price'], 'arrayid' => arrid}
    end
  end

  def updateItemPrice(arrayid)
    a=$papi.getPricesByHashname($prices[arrayid]['appid'], $prices[arrayid]['item_hash_name'])
    if a['success'] == true
      price = a['lowest_price'].match(/[.]*(\d+[.|,]+\d+)[.]*/)[1]
      price = (price.to_f * 100).to_i
      $prices[arrayid]['item_cost'] = price
      $prices[arrayid]['last_update'] = Time.now()
      fetchprice=Price.find(arrayid)
      fetchprice['item_cost'] = price
      fetchprice['last_update'] = $prices[arrayid]['last_update']
      fetchprice.save
      return {'success' => 1, 'price' => price}
      puts "Updated!"
    else
      return {'success' => -1, 'price' => -1}
      puts "Not updated"
    end
  end

end
