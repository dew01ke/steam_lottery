class LotController < ApplicationController

  #Отдельные страницы раздач
  def draw
    #Получаем параметр
    request_id = params[:lotid].to_i

    #Проверяем на число
    if request_id.is_a? Integer
      #Ищем среди активных раздач
      lotid=$LotGrid.index{|x| x['global_id'] == request_id.to_i}
      #Если нашли
      if (lotid.nil? == false)
        @this_lot = $LotGrid[lotid]
        @this_gid = $LotGrid[lotid]['global_id']
      else
        #проверка архивных
        a=ShortFinishedRaffle.where(id: request_id)
        if (a.count == 1)
          a=ShortFinishedRaffle.find(request_id)
          @this_lot = {'global_id' => request_id, 'data' => {'winner' => a['winner_id'], 'slots' => a['slots'], 'slot_price' => a['slot_price'], 'item' => {'display_name_rus' => $prices[a['price_id']]['display_name_rus'], 'display_name_eng' => $prices[a['price_id']]['display_name_eng'], 'quality_rus' => $qualities_rus[$prices[a['price_id']]['appid'].to_s][$prices[a['price_id']]['quality'].to_i - 1], 'quality_eng' => $qualities_eng[$prices[a['price_id']]['appid'].to_s][$prices[a['price_id']]['quality'].to_i - 1], 'quality_color' => $quality_color[$prices[a['price_id']]['appid'].to_s][$prices[a['price_id']]['quality'].to_i - 1], 'appid' => $prices[a['price_id']]['appid']}}}
          @this_gid = request_id
        else
          #если не нашли в архтвных, то возвращаем ошибку
          @this_lot = {}
          @this_gid = -1
        end
      end
    end
  end

  def testgrid
  end

  #функция генерации новой раздачи
  def generateLot(itemprice)
    itemprice=itemprice.to_i
    #выберем шмотки в интервале 0.9*цена - 1.1*цена, отсортируем по увеличению расхождения с ценой
    price_bounds =0.9*itemprice..1.1*itemprice
    string = "ABS(prices.item_cost-" + itemprice.to_s + ") ASC"
    a=Item.joins(:price).where('prices.item_cost' => price_bounds).order(string).first

    #а если ничегошеньки в этом интервале нет - возьмем ближайшую шмотку дешевле заданного
    if (a.nil?)
      price_bounds =0..1.1*itemprice
      a=Item.joins(:price).where('prices.item_cost' => price_bounds).order(string).first

      #ну или дороже
      if (a.nil?)
        price_bounds =1.1*itemprice..100000
        a=Item.joins(:price).where('prices.item_cost' => price_bounds).order(string).first
      end
    end

    item_price = (1.4*$prices[a['price_id']]['item_cost']).ceil
    puts "Item price*1.4:" + item_price.to_s
    min_slots = [((Math.sqrt(itemprice)-12)/12).ceil, 1].max
    puts "Min slots:" + (min_slots*12).to_s
    max_slots = [((1.3*Math.sqrt(itemprice+20)-2)/12).ceil,1].max
    puts "Max slots:" + (max_slots*12).to_s
    cur_slots = (rand(max_slots - min_slots+1)+min_slots)*12
    puts "Current slots:" + cur_slots.to_s

    slot_cost = (item_price/cur_slots.to_f).ceil
    puts "Slot cost:" + slot_cost.to_s

    total_price = slot_cost * cur_slots
    puts "Total item price:" + total_price.to_s

    item = {'item_steam_id' => a['item_steam_id'], 'price_id' => a['price_id'], 'bot_id' => a['bot_id'], 'display_name_rus' => $prices[a['price_id']]['display_name_rus'], 'display_name_eng' => $prices[a['price_id']]['display_name_eng'], 'quality_rus' => $qualities_rus[$prices[a['price_id']]['appid'].to_s][$prices[a['price_id']]['quality'].to_i - 1], 'quality_eng' => $qualities_eng[$prices[a['price_id']]['appid'].to_s][$prices[a['price_id']]['quality'].to_i - 1], 'quality_color' => $quality_color[$prices[a['price_id']]['appid'].to_s][$prices[a['price_id']]['quality'].to_i - 1], 'appid' => $prices[a['price_id']]['appid'], 'deposited_by' => a['deposited_by']}
    puts item['item_steam_id']
    puts item
    a.destroy

    result = {'item' => item, 'slots' => cur_slots, 'slot_price' => slot_cost, 'winner' => nil}
    return result
  end

  def setLotInGrid(lotid, data)
    lotid=lotid.to_i
    $LotGrid[lotid]['data'] = data
    $LotGrid[lotid]['slot_info'] = Array.new(data['slots'],0)
    $LotGrid[lotid]['vacant'] = 0
    #время начала, тип Time (!) для удобных вычислений, приводится к нужному виду в момент вставки при помощи .strftime("%F %T")
    $LotGrid[lotid]['started'] = Time.now()
    $LotOffset = $LotOffset + 1
    $LotGrid[lotid]['global_id'] = $LotOffset
    puts "Lot " + lotid.to_s + " received offset " + $LotGrid[lotid]['global_id'].to_s
  end

  def finalizeLot(lotid)
    #get winner
    winner = rand($LotGrid[lotid]['data']['slots'].to_i)
    $LotGrid[lotid]['data']['winner'] = $LotGrid[lotid]['slot_info'][winner]
    puts "Winner at lot " + lotid.to_s + " is " + winner.to_s + " with steamid " + $LotGrid[lotid]['data']['winner'].to_s

    if ($LotGrid[lotid]['slot_info'][winner].to_i > 0)
    #award winner
    a=PendingItem.new
    a['item_steam_id'] = $LotGrid[lotid]['data']['item']['item_steam_id']
    a['price_id'] = $LotGrid[lotid]['data']['item']['price_id']
    a['bot_id'] = $LotGrid[lotid]['data']['item']['bot_id']
    a['user_id'] = $LotGrid[lotid]['slot_info'][winner]
    a.save
    puts a['item_steam_id'].to_s + "  " + a['price_id'].to_s + "  " + a['bot_id'].to_s + "  " + a['user_id'].to_s

    #save raffle info
    b=ShortFinishedRaffle.new
    b['id'] = $LotGrid[lotid]['global_id']
    b['item_steam_id'] = $LotGrid[lotid]['data']['item']['item_steam_id']
    b['winner_id'] = $LotGrid[lotid]['slot_info'][winner]
    b['slot_info'] = JSON.generate($LotGrid[lotid]['slot_info'])
    b['slots'] = $LotGrid[lotid]['data']['slots']
    b['slot_price'] = $LotGrid[lotid]['data']['slot_price']
    b['price_id'] = $LotGrid[lotid]['data']['item']['price_id']
    b['started'] = $LotGrid[lotid]['started']
    b.save

    users_participated = $LotGrid[lotid]['slot_info'].uniq
    users_participated.each do |t|
      c=Operation.new
      puts t
      c['user_steamid'] = t
      c['created_at'] = Time.now()
      c['info'] = "Points spent on raffle " + $LotGrid[lotid]['global_id'].to_s
      c['type'] = 1

      c['amount'] = $LotGrid[lotid]['slot_info'].count{|x| x == t} * $LotGrid[lotid]['data']['slot_price']
      c.save
    end

    d=Stat.new
    d['price_id'] = $LotGrid[lotid]['data']['item']['price_id']
    d['finished'] = Time.now()

    tmp_time = Time.now() - $LotGrid[lotid]['started']
    tmp_hours = (tmp_time/3600).to_i
    tmp_minutes = ((tmp_time - tmp_hours*3600)/60).to_i
    tmp_seconds = (tmp_time - tmp_hours*3600 - tmp_minutes*60).to_i

    d['total_time'] = tmp_hours.to_s + ":" + tmp_minutes.to_s + ":" + tmp_seconds.to_s
    puts "Total time:" + tmp_hours.to_s + ":" + tmp_minutes.to_s + ":" + tmp_seconds.to_s
    d.save
    end

    #generate new raffle
    #push to queue
    setLotInQueue(lotid,generateLot(rand($LotGrid[lotid]['maxprice']-$LotGrid[lotid]['minprice']+1)+$LotGrid[lotid]['minprice']))
  end

  def setLotInQueue(lotid, data)
    a = {'lotid' => lotid, 'data' => data}
    $LotQueue.push(a)
    puts "Lot number " + lotid.to_s + " is prepared in queue"
    $LotQueueCounter = $LotQueueCounter + 1
    puts $LotQueueCounter.to_s + " lots in queue"
    if ($LotQueueCounter > ($LotGrid.size*0.4).to_i)
      puts "Critical mass reached, pushing"
      pushQueue()
    end
  end

  def pushQueue

    $LotQueue.each do |t|
      setLotInGrid(t['lotid'],t['data'])
      puts "Pushing in slot " + t['lotid'].to_s
    end
    $LotQueue = []
    $LotQueueCounter = 0
  end

end