class GatewayController < ApplicationController



  def testbuy
    puts buySlot(params[:lotid],params[:slotid])
    redirect_to '/lot/testgrid'
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
    $LotGrid[lotid]['slot_info'][slotid] = session['steam_id']

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
    $LotGrid[lotid]['vacant'] = $LotGrid[lotid]['vacant'] + 1

    #проверим, закончилась ли раздача
    if ($LotGrid[lotid]['vacant'] == $LotGrid[lotid]['data']['slots'])
      puts "Finalizing lot"
      $lot.finalizeLot(lotid)
    end
    puts "Success"
  end

end