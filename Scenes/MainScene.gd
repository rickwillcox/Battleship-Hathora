extends Node2D
# web app id 2a7643ea6266be71cc56c79aa8eb5048935c09d9ca243995f486263071c4f1ca
export var open_in_browser : bool 
export var copy_state_id : bool

var enemy_ships_array : Array = []
var cannonballs_array : Array = []
var game_started : bool = false
var first_packet : bool = true
var just_joined : bool = true
var ship_colours : Array = ["black_ship", "blue_ship", "green_ship", "white_ship", "red_ship,", "yellow_ship"]
var ship_count : int = 0

# Nodes
onready var gui : CanvasLayer = get_node("Gui")
onready var title : Label = get_node("Gui/Title")
onready var create_lobby : TextureButton = get_node("Gui/CreateLobby")
onready var create_lobby_text : Label = get_node("Gui/CreateLobbyText")
onready var join_lobby : TextureButton = get_node("Gui/JoinLobby")
onready var join_lobby_text : Label = get_node("Gui/JoinLobbyText")
onready var join_lobby_state_id : LineEdit = get_node("Gui/JoinLobbyStateID")
onready var state_id : Label = get_node("StateID")
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

func process_data_packets(data):
	# is this the first packet (state ID)
	if first_packet:
		if HathoraConnection.mode == "create_lobby":
			print(data)
			state_id.text = data
			if open_in_browser:
				OS.shell_open("https://ship-battle-json.surge.sh/" + state_id.text)
			if copy_state_id:
				OS.set_clipboard(data)
			first_packet = false
			return
	
	var dict_data : Dictionary = parse_json(data)
		
	# Is this the first json packet I received?	
	if just_joined:
		if dict_data.has("ships"):
			print(dict_data.ships)
			print(dict_data.ships.size())
			spawn_own_ship(dict_data.ships, dict_data.ships.size() - 1)
			if dict_data.ships.size() > 1:
				print(dict_data.ships.size())
				print("dict_data.ships.size()test")
				for i in range(dict_data.ships.size() -1):
					print(i)
					spawn_enemy_ships(dict_data.ships[i], i)
		if dict_data.has("cannonBalls"):
			if dict_data.cannonBalls.size() > 1:
				for i in range(dict_data.cannonBalls.size()):
					spawn_cannonballs(dict_data.cannonBalls[i])
		just_joined = false
		return
	
	# What happens once game is running	
	if dict_data.has("ships"):
		update_ships(dict_data.ships)
	if dict_data.has("cannonBalls"):
		update_cannonballs(dict_data.cannonBalls)

func send_movement_orders():
	var rand1 = randi() % 255
	var rand2 = randi() % 255
	var rand3 = randi() % 255
	var rand4 = randi() % 255
	var pba : PoolByteArray 
		
	# Movement
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
	
	# Fire Canonball
	if Input.is_action_pressed("Fire"):
		pba = PoolByteArray ([02, rand1+1, rand2+1, rand3+1, rand4+1])
		HathoraConnection.send_message_to_server(pba)
	
func update_ships(ship_data : Array):
	for server_ship in ship_data:
		var ship_found = false
		for client_ship in ships_ysort.get_children():
			if client_ship.id == server_ship.player:
				ship_found = true
				client_ship.update_ship(server_ship)
		if !ship_found:
			spawn_enemy_ships(server_ship, ship_data.find(server_ship, 0))
	 

func update_cannonballs(cannonball_data : Array):
	var server_cannonballs_removed : Array = []
	var new_server_cannonballs : Array = []
	# update existing cannonnballs and add new ones
	for server_cannonball in cannonball_data:
		var server_cannonball_found = false
		for client_cannonball in cannonballs_ysort.get_children():
			if client_cannonball.id == server_cannonball.id:
				client_cannonball.update_cannonball(server_cannonball)
				client_cannonball.found = true
				server_cannonball_found = true
				break
			
		if !server_cannonball_found:
			spawn_cannonballs(server_cannonball)

func start_game():
	join_the_server()

func join_the_server():
	HathoraConnection.connect_to_websocket()

func spawn_own_ship(ship_data : Array, index : int):
	if ship_count <= 6:
		var player_ship = ship.instance()
		player_ship.ship_colour_index = index
		player_ship.position.x = ship_data[-1].x
		player_ship.position.y = ship_data[-1].y
		player_ship.rotation = ship_data[-1].angle - 90
		player_ship.id = ship_data[-1].player
		ships_ysort.add_child(player_ship)
	
func spawn_enemy_ships(ship_data : Dictionary, index : int):
	if ship_count <= 6:
		var enemy_ship = ship.instance()
		enemy_ship.ship_colour_index = index
		enemy_ship.position.x = ship_data.x
		enemy_ship.position.y = ship_data.y
		enemy_ship.rotation = ship_data.angle - 90
		enemy_ship.id = ship_data.player
		ships_ysort.add_child(enemy_ship)

func spawn_cannonballs(cannonball_data : Dictionary):
	var cannonball_instance = cannonball.instance()
	cannonball_instance.position.x = cannonball_data.x
	cannonball_instance.position.y = cannonball_data.y
	cannonball_instance.new_position = Vector2(cannonball_data.x, cannonball_data.y)
	cannonball_instance.id = cannonball_data.id
	cannonballs_ysort.add_child(cannonball_instance)

func _on_AnimationPlayer_animation_finished(anim_name):
	gui.queue_free()
	
func _on_CreateLobby_pressed():
	create_lobby.disabled = true
	create_lobby.modulate = Color("a49f9f")
	HathoraConnection.mode = "create_lobby"
	title.get_node("AnimationPlayer").play("Fade")
	yield(get_tree().create_timer(3), "timeout")
	start_game()

func _on_JoinLobby_pressed():
	HathoraConnection.state_id = join_lobby_state_id.text
	state_id.text = join_lobby_state_id.text
	join_lobby.disabled = true
	join_lobby.modulate = Color("a49f9f")
	HathoraConnection.mode = "join_lobby"
	title.get_node("AnimationPlayer").play("Fade")
	start_game()

func _on_JoinLobbyStateID_text_changed():
	HathoraConnection.state_id = join_lobby_state_id.text
