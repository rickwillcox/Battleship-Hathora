extends TextureProgress

var int_delta : float = 0
var can_play_reload : bool = true

func _physics_process(delta):
	if value >= 15:
		can_play_reload = true
		int_delta = 0
	else:
		can_play_reload = false
		int_delta += delta
		if int_delta >= 0.1:
			value +=1
			int_delta -= 0.1


		
