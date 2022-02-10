extends Sprite

onready var animation_player = get_node("AnimationPlayer")

func _ready():
	animation_player.play("Explosion")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
