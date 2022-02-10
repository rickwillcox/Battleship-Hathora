extends Sprite

var id : int

func _ready():
	pass
	
func _on_collision():
	queue_free()
