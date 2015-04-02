class StatsController < ApplicationController
  def teststats
    @a=getActiveUsers(1)
    @b=getAverageSpendings(1)
    @c=getFinishedLotPriceTable(1,100)
    @d=getAverageTimePriceTable(1,500)
    @e=getAverageTimeItemTable(15)
  end

  def getActiveUsers(days)
    cur_time = Time.now()
    begin_time = cur_time - (days*60*60*24)
    begin_time_rd = Time.new(begin_time.year,begin_time.month,begin_time.day)
    return a=Operation.where("created_at" => begin_time_rd..cur_time).group("user_steamid").count.count
  end

  def getAverageSpendings(days)
    cur_time = Time.now()
    begin_time = cur_time - (days*60*60*24)
    begin_time_rd = Time.new(begin_time.year,begin_time.month,begin_time.day)
    sum = 0
    a=Operation.where("created_at" => begin_time_rd..cur_time).group("user_steamid").sum("amount").values.each do |t|
      sum = sum + t
    end
    if a.size==0
      return 0
    else
      return sum / a.size
    end
  end

  def getFinishedLotPriceTable(days,interval)
    cur_time = Time.now()
    begin_time = cur_time - (days*60*60*24)
    begin_time_rd = Time.new(begin_time.year,begin_time.month,begin_time.day)
    min_price = Price.all.order("item_cost ASC").first['item_cost']
    max_price = Price.all.order("item_cost DESC").first['item_cost']

    a=[]
    while min_price<max_price
      a.push([min_price, min_price+interval, Stat.joins(:price).where("finished" => begin_time_rd..cur_time, "prices.item_cost" => min_price..min_price+interval).count])
      min_price = min_price + interval
    end
    return a
  end

  def getAverageTimePriceTable(days,interval)
    cur_time = Time.now()
    begin_time = cur_time - (days*60*60*24)
    begin_time_rd = Time.new(begin_time.year,begin_time.month,begin_time.day)
    min_price = Price.all.order("item_cost ASC").first['item_cost']
    max_price = Price.all.order("item_cost DESC").first['item_cost']

    a=[]
    while min_price<max_price
      t=Stat.joins(:price).where("finished" => begin_time_rd..cur_time, "prices.item_cost" => min_price..min_price+interval).average("TIME_TO_SEC(total_time)")
      a.push([min_price, min_price+interval, t.to_i])
      min_price = min_price + interval
    end
    return a
  end

  def getAverageTimeItemTable(days)
    cur_time = Time.now()
    begin_time = cur_time - (days*60*60*24)
    begin_time_rd = Time.new(begin_time.year,begin_time.month,begin_time.day)
    itemstotal=$prices.size
    a=[]
    $prices.each.with_index {|x, index|
      if (x.nil? == false)
        a.push([x['item_hash_name'], Stat.where("finished" => begin_time_rd..cur_time, "price_id" => index).average("TIME_TO_SEC(total_time)").to_i])
        puts index
      end
    }

    return a.sort_by{|x| -x[1]}
  end
end