class GatewayController < ApplicationController

  #Запрещаем вывод в лайоут
  layout false

  def testbuy
    puts buySlot(params[:lotid],params[:slotid])
    redirect_to '/lot/testgrid'
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