puts ">>Application started"

$http = NetController.new
$papi = PapiController.new

#init lot grid
$LotGrid = []
$LotGrid.push({'minprice' => 10, 'maxprice' => 25, 'data' => {}})
$LotGrid.push({'minprice' => 25, 'maxprice' => 50, 'data' => {}})
$LotGrid.push({'minprice' => 50, 'maxprice' => 80, 'data' => {}})
$LotGrid.push({'minprice' => 80, 'maxprice' => 110, 'data' => {}})

#create lot queue
$LotQueue = []