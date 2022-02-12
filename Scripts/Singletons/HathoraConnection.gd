extends Node

var token_results : String
var state_id : String
var app_id : String
var mode : String
var first_packet : bool = true

var _client = WebSocketClient.new()

func _ready():
	get_parent().get_node("MainScene/HTTPRequest").connect("http_results", self, "_on_http_results_received")
	
func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_client.get_peer(1).put_packet(token_results.to_utf8())
	if (mode == "create_lobby"):
		var x : PoolByteArray = []
		_client.get_peer(1).put_packet(x)
	elif (mode == "join_lobby"):
		print(state_id)
		_client.get_peer(1).put_packet(state_id.to_utf8())
		_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)
		var pba : PoolByteArray = [00, 12, 55, 23, 254]		
		send_message_to_server(pba)
	else:
		assert(false)
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)
	if first_packet:
		first_packet = false
#		yield(get_tree().create_timer(0.3), "timeout")
		get_parent().get_node("MainScene").set_physics_process(true)
	
	
	
func _on_data():
	get_parent().get_node("MainScene").process_data_packets(_client.get_peer(1).get_packet().get_string_from_utf8())

		

func _process(delta):
	_client.poll()


func connect_to_websocket():
	
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	var websocket_url : String = "wss://rtag.dev/%s" % app_id
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _on_http_results_received(tr, si, ai):
	token_results = tr
	state_id = si
	app_id = ai
	print("HTTP Request Finished")

func send_message_to_server(pba : PoolByteArray):
	_client.get_peer(1).put_packet(pba)
