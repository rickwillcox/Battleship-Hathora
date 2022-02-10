extends Node2D

var enemy_ships_array : Array = []
var cannonballs_array : Array = []
var game_started : bool = false

# Nodes
onready var title : Label = get_node("Title")
onready var ships_ysort : YSort = get_node("Ships")
onready var cannonballs_ysort : YSort = get_node("Cannonballs")
onready var http_request : HTTPRequest = get_node("HTTPRequest")

# Scenes
onready var ship = preload("res://Scenes/Ship.tscn")
onready var cannonball = preload("res://Scenes/Cannonball.tscn")

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	send_movement_orders()
	update_player_ship()
	update_enemy_ships()
	update_cannonballs()

func send_movement_orders():
	var sending_move_order = false
	var rand1 = randi() % 255
	var rand2 = randi() % 255
	var rand3 = randi() % 255
	var rand4 = randi() % 255
	
	if Input.is_action_pressed("Forward"):
		var pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 02, 01])
		sending_move_order = true
		HathoraConnection.send_message_to_server(pba)
		
	if Input.is_action_pressed("Right"):
		var pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 01, 00])
		sending_move_order = true
		HathoraConnection.send_message_to_server(pba)

	if Input.is_action_pressed("Left"):
		var pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 00, 00])
		sending_move_order = true
		HathoraConnection.send_message_to_server(pba)
	
#	if (!sending_move_order):
#		var pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 02, 00])
#		HathoraConnection.send_message_to_server(pba)
	
		
	
func update_player_ship():
	pass

func update_enemy_ships():
	pass
	
func update_cannonballs():
	pass

func start_game():
	join_the_server()
	spawn_own_ship()
	spawn_enemy_ships()
	spawn_cannonballs()
	set_physics_process(true)

func join_the_server():
	HathoraConnection.connect_to_websocket()


func spawn_own_ship():
	var player_ship = ship.instance()
	player_ship.position.x = 200
	player_ship.position.y = 200
	player_ship.rotation = 50
	ships_ysort.add_child(player_ship)
	
func spawn_enemy_ships():
	for es in enemy_ships_array:
		var enemy_ship = ship.instance()
		enemy_ship.position.x = 80
		enemy_ship.position.y = 80
		enemy_ship.rotation = 80
		ships_ysort.add_child(enemy_ship)

func spawn_cannonballs():
	for cb in cannonballs_array:
		var cannonball_instance = cannonball.instance()
		cannonball_instance.position.x = 80
		cannonball_instance.position.y = 80
		cannonball_instance.id = 1
		cannonballs_ysort.add_child(cannonball_instance)


func _on_AnimationPlayer_animation_finished(anim_name):
	title.queue_free()


func _on_TitleTimer_timeout():
	title.get_node("AnimationPlayer").play("Fade")
	start_game()
