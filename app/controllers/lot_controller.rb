class LotController < ApplicationController

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

    item_price = (1.4*a.price['item_cost']).ceil
    puts "Item price*1.4:" + item_price.to_s
    min_slots = [((Math.sqrt(itemprice)-12)/8).ceil, 1].max
    puts "Min slots:" + (min_slots*8).to_s
    max_slots = [((1.3*Math.sqrt(itemprice+20)-2)/8).ceil,1].max
    puts "Max slots:" + (max_slots*8).to_s
    cur_slots = (rand(max_slots - min_slots+1)+min_slots)*8
    puts "Current slots:" + cur_slots.to_s

    slot_cost = (item_price/cur_slots.to_f).ceil
    puts "Slot cost:" + slot_cost.to_s

    total_price = slot_cost * cur_slots
    puts "Total item price:" + total_price.to_s

    item = {'item_steam_id' => a['item_steam_id'], 'price_id' => a['price_id'], 'deposited_by' => a['deposited_by'], 'created_at' => a['created_at'], 'bot_id' => a['bot_id']}
    a.destroy

    result = {'item' => item, 'slots' => cur_slots, 'slot_price' => slot_cost}
    return result
  end

  def setLotInGrid(lotid, data)
    lotid=lotid.to_i
    $LotGrid[lotid]['data'] = data
    $LotGrid[lotid]['slot_info'] = Array.new(data['slots'],0)
    $LotGrid[lotid]['vacant'] = 0
  end

  def finalizeLot(lotid)
    #get winner
    winner = rand($LotGrid[lotid]['data']['slots'].to_i)
    puts "Winner at lot " + lotid.to_s + " is " + winner.to_s + " with steamid " + $LotGrid[lotid]['slot_info'][winner]

    #award winner
    a=PendingItem.new
    a['item_steam_id'] = $LotGrid[lotid]['data']['item']['item_steam_id']
    a['price_id'] = $LotGrid[lotid]['data']['item']['price_id']
    a['bot_id'] = $LotGrid[lotid]['data']['item']['bot_id']
    a['user_id'] = $LotGrid[lotid]['slot_info'][winner]
    a.save
    puts a['item_steam_id'].to_s + "  " + a['price_id'].to_s + "  " + a['bot_id'].to_s + "  " + a['user_id'].to_s

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
    if ($LotQueueCounter > 1)
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