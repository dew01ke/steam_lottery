puts ">>Application started"

$http = NetController.new
$papi = PapiController.new
$lot = LotController.new

$qualities_rus = {'570' => ["Частое", "Нечастое", "Редкое", "Мифическое", "Легендарное", "Древнее", "Чрезвычайно редкое"], "730" => ["Потребительская серия", "Промышленная серия", "Военная серия", "Ограниченная серия", "Засекреченная серия", "Тайная серия", "Нож"]}
$qualities_eng = {'570' => ["Common", "Uncommon", "Rare", "Mythical", "Legendary", "Ancient", "Arcana"], '730' => ["Consumer grade", "Industrial grade", "Mil-spec", "Restricted", "Classified", "Covert", "Melee Weapon"]}
$quality_color = {'570' => ["common", "uncommon", "rare", "mythical", "legendary", "ancient", "arcana"], '730' => ["common", "uncommon", "rare", "mythical", "legendary", "ancient", "immortal"]}

all_prices = Price.all
$prices = Array.new(all_prices.last['id'])
all_prices.each do |t|
  $prices[t[:id]] = {'item_hash_name' => t['item_hash_name'],'item_cost' => t['item_cost'],'last_update' => t['last_update'],'quality' => t['quality'],'display_name_rus' => t['display_name_rus'],'display_name_eng' => t['display_name_eng'], 'appid' => t['appid']}
end

if  (ShortFinishedRaffle.all.size == 0)
  $LotOffset = 0
else
  $LotOffset = ShortFinishedRaffle.all.last['id']
end

#init lot grid
$LotGrid = []
$LotGrid.push({'minprice' => 10, 'maxprice' => 40, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 60, 'maxprice' => 150, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 200, 'maxprice' => 380, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 380, 'maxprice' => 610, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 700, 'maxprice' => 950, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 1000, 'maxprice' => 1310, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 1380, 'maxprice' => 1710, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 1780, 'maxprice' => 2710, 'data' => {}, 'slot_info' => []})

$LotID = Array.new($LotGrid.size,0)

$lot.setLotInGrid(0,$lot.generateLot(20))
$lot.setLotInGrid(1,$lot.generateLot(100))
$lot.setLotInGrid(2,$lot.generateLot(250))
$lot.setLotInGrid(3,$lot.generateLot(500))
$lot.setLotInGrid(4,$lot.generateLot(800))
$lot.setLotInGrid(5,$lot.generateLot(1200))
$lot.setLotInGrid(6,$lot.generateLot(1500))
$lot.setLotInGrid(7,$lot.generateLot(2050))
#create lot queue
$LotQueue = []
$LotQueueCounter = 0

