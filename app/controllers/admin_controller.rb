class AdminController < ApplicationController

  def cancel
    cancelLot(params[:gridid])
    redirect_to '/'
  end

  def editrange
    editSlotRange(params[:slotid], params[:minprice], params[:maxprice])
    redirect_to '/'
  end

  def testadminstats
    @a=getTotalBotCost(1)
    itemPoolStats
  end

  def banUser(steamid)
    a=User.where('steam64' => steamid.to_i).first
    if a.size == 0
      return {'success' => 'false', 'message' => 'User not found'}
    else
      a['banned'] = true
      a.save
      return {'success' => 'true', 'message' => ''}
    end
  end

  def cancelLot(gridid)
    gridid= gridid.to_i

    #получаем список участников
    users_participated = $LotGrid[gridid]['slot_info'].uniq
    #и возвращаем деньги
    users_participated.each do |t|
      t=t.to_i
      if (t>0)
        puts t
        spent = $LotGrid[gridid]['slot_info'].count{|x| x == t.to_s} * $LotGrid[gridid]['data']['slot_price'].to_i
        puts spent
        a=User.where('steam64' => t.to_i).first
        a['points'] = a['points'] + spent
        a.save
      end
    end

    #возвращаем шмотку в пул
    a = Item.new
    a['item_steam_id'] = $LotGrid[gridid]['data']['item']['item_steam_id'].to_i
    a['price_id'] = $LotGrid[gridid]['data']['item']['price_id'].to_i
    a['deposited_by'] = $LotGrid[gridid]['data']['item']['deposited_by'].to_i
    a['created_at'] = Time.now()
    a['bot_id'] = $LotGrid[gridid]['data']['item']['bot_id'].to_i
    a.save

    #перезапишем инфу для корректной финализации
    $LotGrid[gridid]['slot_info'] = Array.new($LotGrid[gridid]['data']['slots'], -1)
    $LotGrid[gridid]['vacant'] = $LotGrid[gridid]['data']['slots']
    $lot.finalizeLot(gridid)
  end

  def editSlotRange(slotid, minprice, maxprice)
    slotid = slotid.to_i
    $LotGrid[slotid]['minprice'] = minprice.to_i
    $LotGrid[slotid]['maxprice'] = maxprice.to_i
  end

  def getTotalBotCost(botid)
    a=Item.where('bot_id' => botid.to_i)
    sum=0
    if (a.size>0)
      a.each do |t|
        sum = sum + $prices[t['price_id'].to_i]['item_cost'].to_i
      end
    else
      return 0
    end
    return sum
  end

  def itemPoolStats
    puts a=Item.all.group('price_id').count
    a.each do |t|
      puts t[0].to_s + " " + t[1].to_s
    end
  end
end