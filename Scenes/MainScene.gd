extends Node2D

var enemy_ships_array : Array = []
var cannonballs_array : Array = []
var game_started : bool = false

# Nodes
onready var gui : CanvasLayer = get_node("Gui")
onready var title : Label = get_node("Gui/Title")
onready var create_lobby : TextureButton = get_node("Gui/CreateLobby")
onready var create_lobby_text : Label = get_node("Gui/CreateLobby/CreateLobbyText")
onready var join_lobby : TextureButton = get_node("Gui/JoinLobby")
onready var join_lobby_text : Label = get_node("Gui/JoinLobby/JoinLobbyText")
onready var join_lobby_state_id : TextEdit = get_node("Gui/JoinLobby/JoinLobbyStateID")
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

func process_data_packets(data):
	print(data)
	pass

func send_movement_orders():
	var rand1 = randi() % 255
	var rand2 = randi() % 255
	var rand3 = randi() % 255
	var rand4 = randi() % 255
	var pba : PoolByteArray 
		
	
	if Input.is_action_pressed("Forward"):
		pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 02, 01])
		if Input.is_action_pressed("Right"):
			pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 01, 01])
		elif Input.is_action_pressed("Left"):
			pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 00, 01])
				
	elif Input.is_action_pressed("Right"):
		pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 01, 00])

	elif Input.is_action_pressed("Left"):
		pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 00, 00])
		
	else:
		pba = PoolByteArray ([01, rand1, rand2, rand3, rand4, 02, 00])
		
	HathoraConnection.send_message_to_server(pba)

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
	gui.queue_free()
	
func _on_CreateLobby_pressed():
	HathoraConnection.mode = "create_lobby"
	title.get_node("AnimationPlayer").play("Fade")
	yield(get_tree().create_timer(3), "timeout")
	start_game()


func _on_JoinLobby_pressed():
	HathoraConnection.mode = "join_lobby"
	title.get_node("AnimationPlayer").play("Fade")
	start_game()


func _on_JoinLobbyStateID_text_changed():
	HathoraConnection.state_id = join_lobby_state_id.text
