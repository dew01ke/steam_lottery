class GatewayController < ApplicationController

  def testbuy
    puts buySlot(params[:lotid],params[:slotid])
    redirect_to '/lot/testgrid'
  end

  def buyslot
    respond_to do |format|
      format.json{
        @a=buySlot(params[:lotid],params[:slotid]).to_s.html_safe
      }
    end
  end

  def getgrid
    respond_to do |format|
      format.json{
        @a=getGrid.to_s.html_safe
      }
    end
  end

  def getslots
    respond_to do |format|
      format.json{
        @a=getSlots(params[:lotid]).to_s.html_safe
      }
    end
  end

  def getending
    respond_to do |format|
      format.json{
        @a=getEnding.to_s.html_safe
      }
    end
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
      percentage[lotid] = t['vacant']/ t['data']['slots'].to_f
    end
    lot1=percentage.index(percentage.max)
    percentage[lot1]=-1
    lot2=percentage.index(percentage.max)
    percentage[lot2]=-1
    lot3=percentage.index(percentage.max)
    tmp=[]
    tmp.push({'reference_id' => $LotID[lot1], 'display_name_rus' => $LotGrid[lot1]['data']['item']['display_name_rus'], 'display_name_eng' => $LotGrid[lot1]['data']['item']['display_name_eng'], 'quality_rus' => $LotGrid[lot1]['data']['item']['quality_rus'], 'quality_eng' => $LotGrid[lot1]['data']['item']['quality_eng'], 'total_slots' => $LotGrid[lot1]['data']['slots'], 'quality_color' => $LotGrid[lot1]['data']['item']['quality_color']})
    tmp.push({'reference_id' => $LotID[lot2], 'display_name_rus' => $LotGrid[lot2]['data']['item']['display_name_rus'], 'display_name_eng' => $LotGrid[lot2]['data']['item']['display_name_eng'], 'quality_rus' => $LotGrid[lot2]['data']['item']['quality_rus'], 'quality_eng' => $LotGrid[lot2]['data']['item']['quality_eng'], 'total_slots' => $LotGrid[lot2]['data']['slots'], 'quality_color' => $LotGrid[lot2]['data']['item']['quality_color']})
    tmp.push({'reference_id' => $LotID[lot3], 'display_name_rus' => $LotGrid[lot3]['data']['item']['display_name_rus'], 'display_name_eng' => $LotGrid[lot3]['data']['item']['display_name_eng'], 'quality_rus' => $LotGrid[lot3]['data']['item']['quality_rus'], 'quality_eng' => $LotGrid[lot3]['data']['item']['quality_eng'], 'total_slots' => $LotGrid[lot3]['data']['slots'], 'quality_color' => $LotGrid[lot3]['data']['item']['quality_color']})
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
      tmp.push({'grid_id' => lotid, 'reference_id' => $LotID[lotid], 'display_name_rus' => t['data']['item']['display_name_rus'], 'display_name_eng' => t['data']['item']['display_name_eng'], 'quality_rus' => t['data']['item']['quality_rus'], 'quality_eng' => t['data']['item']['quality_eng'], 'total_slots' => t['data']['slots'], 'myslots' => myslots, 'otherslots' => otherslots, 'quality_color' => t['data']['item']['quality_color']})
    end
    return JSON.generate(tmp)
  end

  def buySlot(referenceid, slotid)
    if (session['steam_id'].nil?)
      return {'success' => false, 'message' => "Not logged in"}
    end
    referenceid=referenceid.to_i
    if ($LotID.count{|x| x == referenceid} == 0)
      return {'success' => false, 'message' => "Trying to access finished lot"}
    end

    lotid=$LotID.index(referenceid)
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