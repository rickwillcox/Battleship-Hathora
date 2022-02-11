extends Sprite

var id : int

var d : Dictionary = {
	"ships":
		[{"player":"kjacjx0qkg",
		"x":833,
		"y":330,
		"angle":0,
		"hitCount":0},
		{"player":"nipr9fuiajm",
		"x":548.9311683901882,
		"y":612.91837016936,
		"angle":0.402,
		"hitCount":0}],
	"cannonBalls":
		[{"id" : 1,
		"x" : 22.5,
		"y" : 50},
		{"id" : 2,
		"x" : 33,
		"y" : 2}]}  


func _ready():
	pass
	
func _on_collision():
	queue_free()

func update_cannonball(data):
	if data.has("x"):
		position.x = data.x
	if data.has("y"):
		position.x = data.y
	
