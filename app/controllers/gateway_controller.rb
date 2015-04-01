class GatewayController < ApplicationController

  require 'digest'
  require 'digest/md5'

  #Запрещаем вывод в лайоут
  layout false

  def testbuy
      #getItemPrice(570,"Sentinel Hood")
  end

  def getinventory
    @a = getInventory(params[:appid]).to_json
    render :json => @a
  end

  def buyslot
    @a = buySlot(params[:lotid], params[:slotid]).to_json
    render :json => @a
  end

  def getgrid
    @a = getGrid.to_json
    render :json => @a
  end

  def getslots
    @a = getSlots(params[:lotid]).to_json
    render :json => @a
  end

  def getending
    @a = getEnding.to_json
    render :json => @a
  end

  def testgateway
    @a = getSlots(params[:lotid])
    @b = getEnding
    @c = getGrid
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
              #
              #
              #

              #Удаляем уведомление, если принято
              if session[:unique_id] == $ActiveTradeOffers[id][toid]['unique_id']
                puts "clear Notification"
                clearNotification()
              end

              #Удаляем принятую
              $ActiveTradeOffers[id].delete_at(toid)
            else
              puts "Tradeoffer was declined by user"

              #Удаляем уведомление, если отклонено
              if session[:unique_id] == $ActiveTradeOffers[id][toid]['unique_id']
                puts "clear Notification"
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

  def makeTradeOffer
    #Уникальный токен для данного действия
    @unique_id = Digest::MD5.hexdigest(session[:steam_id] + Time.now.to_s)[4..8].upcase!

    #НЕТ ФИЛЬТРАЦИИ
    user_appid = params[:appId]
    #НЕТ ФИЛЬТРАЦИИ
    user_items = params[:myitems]
    #Вещи, которые мы хотим забрать
    pick_items = []
    #Ид бота
    bot_id = 1
    #Стоимость вводимых вещей
    items_cost = 0

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

    #Выбираем первого бота
    bot = Bot.find(bot_id)

    #Очищаем все данные - необязательно, ибо куки все перепишутся
    #$http.clearCookie()
    #$http.clearHeader()

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
                        "Referer" => "https://steamcommunity.com/tradeoffer/new/?partner=86493268"
                    })
    #Заполняем сам запрос
    body = {
        "sessionid" => bot.last_sessionid,
        "serverid" => "1",
        "partner" => "76561198046758996",
        "tradeoffermessage" => ("Токен действия: #{@unique_id}"),
        "json_tradeoffer" => '{"newversion":true,"version":2,"me":{"assets":[],"currency":[],"ready":false},"them":{"assets":' + pick_items.to_json + ',"currency":[],"ready":false}}',
        "captcha" => "",
        "trade_offer_create_params" => "{}"
    }

    #Посылаем запрос
    response = $http.httpRequest("POST", APP_CONFIG['steam_trade_url'], body)

    puts response
    #Если ответ вернулся нормальный, то
    if response != -1
      #Парсим ответ
      response_data = JSON.parse(response)

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

  def getInventory(appid)
    steam64 = session[:steam_id].to_i
    inventory = $papi.getBackpack(steam64, appid)

    tmp = []

    inventory['rgInventory'].each do |item|
      current = inventory['rgDescriptions'][item[1]['classid'].to_s + '_' + item[1]['instanceid'].to_s]

      if current['tradable'] == 1
        price_result = getItemPrice(appid, current['market_hash_name'].to_s)

        #если шмотка новая и нужно вписать название и качество
        if price_result['success'] == 2
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
          quality = $quality_color[appid.to_s].index{|x| x == quality}
          $prices[price_result['arrayid']]['quality'] = quality
          fetchprice = Price.find(price_result['arrayid'])
          fetchprice['quality'] = quality
          fetchprice['display_name_rus'] = current['market_name']
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

    return JSON.generate(tmp)
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
      if (Time.zone.now() - $prices[a]['last_update'] > 24*60*60)
        #шмотка есть в БД, цена старая
        puts "Updating..."
        result = updateItemPrice(a)
        return result
      else
        #шмотка есть в БД, цена норм
        puts "We got the price!"
        return {'success' => 1, 'price' => $prices[a]['item_cost']}
      end
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

  def getSlots(referenceid)
    lotid=$LotGrid.index{|x| x['global_id'] == referenceid.to_i}
    if (lotid.nil? == false)
      lotid.to_i
      return JSON.generate($LotGrid[lotid]['slot_info'])
    else
      a=ShortFinishedRaffle.where(id: referenceid)
      if (a.count == 1)
        a=ShortFinishedRaffle.find(referenceid)
        return JSON.generate(JSON.parse(a['slot_info']))
      end
    end

  end

  def getEnding
    percentage=Array.new($LotGrid.size,0)
    $LotGrid.each.with_index do |t,lotid|
      percentage[lotid] = t['vacant']/ t['data']['slots'].to_f
      if percentage[lotid]>0.98
        percentage[lotid] = -1
      end
    end
    lot1=percentage.index(percentage.max)
    percentage[lot1]=-1
    lot2=percentage.index(percentage.max)
    percentage[lot2]=-1
    lot3=percentage.index(percentage.max)
    tmp=[]
    tmp.push({'global_id' => $LotGrid[lot1]['global_id'], 'display_name_rus' => $LotGrid[lot1]['data']['item']['display_name_rus'], 'display_name_eng' => $LotGrid[lot1]['data']['item']['display_name_eng'], 'quality_rus' => $LotGrid[lot1]['data']['item']['quality_rus'], 'quality_eng' => $LotGrid[lot1]['data']['item']['quality_eng'], 'total_slots' => $LotGrid[lot1]['data']['slots'], 'quality_color' => $LotGrid[lot1]['data']['item']['quality_color'], 'appid' => $LotGrid[lot1]['data']['item']['appid']})
    tmp.push({'global_id' => $LotGrid[lot2]['global_id'], 'display_name_rus' => $LotGrid[lot2]['data']['item']['display_name_rus'], 'display_name_eng' => $LotGrid[lot2]['data']['item']['display_name_eng'], 'quality_rus' => $LotGrid[lot2]['data']['item']['quality_rus'], 'quality_eng' => $LotGrid[lot2]['data']['item']['quality_eng'], 'total_slots' => $LotGrid[lot2]['data']['slots'], 'quality_color' => $LotGrid[lot2]['data']['item']['quality_color'], 'appid' => $LotGrid[lot2]['data']['item']['appid']})
    tmp.push({'global_id' => $LotGrid[lot3]['global_id'], 'display_name_rus' => $LotGrid[lot3]['data']['item']['display_name_rus'], 'display_name_eng' => $LotGrid[lot3]['data']['item']['display_name_eng'], 'quality_rus' => $LotGrid[lot3]['data']['item']['quality_rus'], 'quality_eng' => $LotGrid[lot3]['data']['item']['quality_eng'], 'total_slots' => $LotGrid[lot3]['data']['slots'], 'quality_color' => $LotGrid[lot3]['data']['item']['quality_color'], 'appid' => $LotGrid[lot3]['data']['item']['appid']})
    return JSON.generate(tmp)
  end

  def getGrid
    tmp=[]
    $LotGrid.each.with_index do |t,lotid|
      if (session[:steam_id].nil? ==false)
        myslots = t['slot_info'].count{|x| x==session[:steam_id]}
      else
        myslots = 0
      end
      otherslots = t['vacant'] - myslots
      tmp.push({'grid_id' => lotid, 'global_id' => t['global_id'], 'appid' => t['data']['item']['appid'], 'display_name_rus' => t['data']['item']['display_name_rus'], 'display_name_eng' => t['data']['item']['display_name_eng'], 'quality_rus' => t['data']['item']['quality_rus'], 'quality_eng' => t['data']['item']['quality_eng'], 'total_slots' => t['data']['slots'], 'myslots' => myslots, 'otherslots' => otherslots, 'quality_color' => t['data']['item']['quality_color']})
    end
    return JSON.generate(tmp)
  end

  def buySlot(referenceid, slotid)
    if (session['steam_id'].nil?)
      return {'success' => false, 'message' => "Not logged in"}
    end
    referenceid=referenceid.to_i
    if ($LotGrid.count{|x| x['global_id'] == referenceid} == 0)
      return {'success' => false, 'message' => "Trying to access finished lot"}
    end

    lotid=$LotGrid.index{|x| x['global_id'] == referenceid}
    slotid=slotid.to_i

    #смотрим, не заняли ли слот чуть раньше
    if ($LotGrid[lotid]['slot_info'][slotid] != 0)
      return {'success' => false, 'message' => "Slot occupied"}
    end

    #займем слот на время проверок
    $LotGrid[lotid]['slot_info'][slotid] = -1

    #проверим, хватает ли денег
    a=User.where('steam64' => session['steam_id'])

    #а была ли пони?
    if (a.size == 0)
      puts "ШТА?!"
      $LotGrid[lotid]['slot_info'][slotid] = 0
      return {'success' => false, 'message' => "No such user"}
    end

    puts "User points before:" + a[0]['points'].to_s
    if (a[0]['points'].to_i < $LotGrid[lotid]['data']['slot_price'].to_i)
      $LotGrid[lotid]['slot_info'][slotid] = 0
      puts "Bomzh detected"
      return {'success' => false, 'message' => "Not enough points"}
    end

    #забираем деньги (самая приятная часть!)
    a[0]['points'] = a[0]['points'] - $LotGrid[lotid]['data']['slot_price']
    a[0].save
    puts "User points after:" + a[0]['points'].to_s

    #Обновляем в сессии баланс
    session[:coin_count] = a[0]['points']

    #увеличим счетчик купленных слотов
    $LotGrid[lotid]['slot_info'][slotid] = session['steam_id']
    $LotGrid[lotid]['vacant'] = $LotGrid[lotid]['vacant'] + 1

    #проверим, закончилась ли раздача
    if ($LotGrid[lotid]['vacant'] == $LotGrid[lotid]['data']['slots'])
      puts "Finalizing lot"
      $lot.finalizeLot(lotid)
    end
    puts "Success"
    return {'success' => true, 'message' =>""}
  end

end