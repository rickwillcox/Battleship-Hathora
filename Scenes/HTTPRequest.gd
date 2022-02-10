extends HTTPRequest

signal http_results(token_result, state_id, app_id)

var token_result 

export var state_id : String
export var app_id : String 

func _ready():
	connect("request_completed", self, "_on_request_completed")
	var url = "https://rtag.dev/%s/login/anonymous" % app_id
	print(url)
	var data : Dictionary = {}
	_make_post_request(url, data, true)

func _make_post_request(url, data_to_send, use_ssl):
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
		
func _on_request_completed(result, response_code, headers, body):
	token_result = JSON.parse(body.get_string_from_utf8()).result["token"]
	emit_signal("http_results", token_result, state_id, app_id)
