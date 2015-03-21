class GatewayController < ApplicationController

  def testbuy
    puts buySlot(params[:lotid],params[:slotid])
    redirect_to '/lot/testgrid'
  end

  def testgateway
    @a = getSlots(params[:lotid])
    @b = getEnding
    @c = getGrid
  end

  def getSlots(lotid)
    lotid=lotid.to_i
    return JSON.generate($LotGrid[lotid]['slot_info'])
  end

  def getEnding
    percentage=Array.new($LotGrid.size,0)
    $LotGrid.each.with_index do |t,lotid|
      percentage[lotid] = t['vacant']/ t['data']['slots']
    end
    lot1=percentage.index(percentage.max)
    percentage[lot1]=-1
    lot2=percentage.index(percentage.max)
    percentage[lot2]=-1
    lot3=percentage.index(percentage.max)
    tmp=[{'lot' => $LotGrid[lot1]['data'], 'lotid' => lot1},{'lot' => $LotGrid[lot2]['data'], 'lotid' => lot2},{'lot' => $LotGrid[lot3]['data'], 'lotid' => lot3}]
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
      tmp.push({'display_name_rus' => t['data']['item']['display_name_rus'], 'display_name_eng' => t['data']['item']['display_name_eng'], 'quality_rus' => t['data']['item']['quality_rus'], 'quality_eng' => t['data']['item']['quality_eng'], 'total_slots' => t['data']['slots'], 'myslots' => myslots, 'otherslots' => otherslots})
    end
    return tmp
  end

  def buySlot(lotid, slotid)
    if (session['steam_id'].nil?)
      return "Not logged in"
    end
    lotid=lotid.to_i
    slotid=slotid.to_i

    #смотрим, не заняли ли слот чуть раньше
    if ($LotGrid[lotid]['slot_info'][slotid] != 0)
      return "Slot occupied"
    end

    #займем слот на время проверок
    $LotGrid[lotid]['slot_info'][slotid] = -1

    #проверим, хватает ли денег
    a=User.where('steam64' => session['steam_id'])

    #а была ли пони?
    if (a.size == 0)
      puts "ШТА?!"
      $LotGrid[lotid]['slot_info'][slotid] = 0
      return "No such user"
    end

    puts "User points before:" + a[0]['points'].to_s
    if (a[0]['points'].to_i < $LotGrid[lotid]['data']['slot_price'].to_i)
      $LotGrid[lotid]['slot_info'][slotid] = 0
      puts "Bomzh detected"
      return -2
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
  end

end