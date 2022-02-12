extends Sprite

export var cannonball_speed : int = 400
var id : int
var new_position : Vector2 
var found : bool = false

func _ready():
	pass

func _physics_process(delta):
	position = position.move_toward(new_position, delta * cannonball_speed)
	
func _on_collision():
	queue_free()

func update_cannonball(data):
	if data.has("x"):
		new_position.x = data.x
	if data.has("y"):
		new_position.y = data.y
	
