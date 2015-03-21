puts ">>Application started"

$http = NetController.new
$papi = PapiController.new
$lot = LotController.new

$qualities_rus = {'570' => ["Частое", "Нечастое", "Редкое", "Мифическое", "Легендарное", "Древнее", "Чрезвычайно редкое"], "730" => ["Потребительская серия", "Промышленная серия", "Военная серия", "Ограниченная серия", "Засекреченная серия", "Тайная серия", "Нож"]}
$qualities_eng = {'570' => ["Common", "Uncommon", "Rare", "Mythical", "Legendary", "Immortal", "Arcana"], '730' => ["Consumer grade", "Industrial grade", "Mil-spec", "Restricted", "Classified", "Covert", "Melee Weapon"]}

#init lot grid
$LotGrid = []
$LotGrid.push({'minprice' => 10, 'maxprice' => 25, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 25, 'maxprice' => 50, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 50, 'maxprice' => 80, 'data' => {}, 'slot_info' => []})
$LotGrid.push({'minprice' => 80, 'maxprice' => 110, 'data' => {}, 'slot_info' => []})
$lot.setLotInGrid(0,$lot.generateLot(20))
$lot.setLotInGrid(1,$lot.generateLot(100))
$lot.setLotInGrid(2,$lot.generateLot(480))
$lot.setLotInGrid(3,$lot.generateLot(950))
#create lot queue
$LotQueue = []
$LotQueueCounter = 0