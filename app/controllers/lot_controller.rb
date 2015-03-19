class LotController < ApplicationController

  def testgen
    @itemprice=params[:cost].to_i
    @a=generateLot(params[:cost])
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

    result = {'item' => a, 'slots' => cur_slots, 'slot_price' => slot_cost}
    return result
  end

  def setLot(lotid, data)
    $LotGrid[lotid]['data'] = data
    $LotGrid[lotid]['slots']=Array.new(data['slots'],0)
  end

end