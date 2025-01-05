extends Node

class_name GenericServerClient

@export var host: String = "localhost"
@export var port: int = 8080
@export var path: String = "/game"

@export var debug: bool = true

# auth params
var email: String # TODO UNUSED
var password: String
var username: String

var socket: WebSocketPeer = WebSocketPeer.new()

func _ready():
	set_process(false)

func connectToServer():
	var url = 'ws://%s:%s%s' % [host, port, path]
	print(url)
	
	var err = socket.connect_to_url(url)
	
	if err != OK:
		print("Unable to connect")
	else:
		set_process(true)

func onReceive(_op: int, _state: Variant) -> void:
	pass # you should override this method in the derived class
	
func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var data = socket.get_packet().get_string_from_utf8()
			# print("Got data from server: %s" % [data])
			var json = JSON.new()
			var err = json.parse(data)
			if err == OK:
				var o = json.data
				_onReceive(o)
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false)
	
func _onReceive(o: Variant):
	var state = null
	
	if o.payload && o.payload != null:
		var json = JSON.new()
		var err = json.parse(o.payload)
		if err == OK: state = json.data
	
	onReceive(o.op, state)

func _send(op, state):
	socket.send_text(JSON.stringify({
		op = op,
		payload = JSON.stringify(state),
	}))
