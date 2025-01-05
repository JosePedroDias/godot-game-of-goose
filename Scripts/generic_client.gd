extends Node

class_name GenericServerClient

# https://docs.godotengine.org/en/stable/tutorials/networking/websocket.html
# https://github.com/godotengine/godot-demo-projects/blob/master/networking/websocket_chat/websocket/WebSocketClient.gd

#@export var debug: bool = true

signal connected_to_server()
signal connection_closed()
#signal message_received(message: Variant)

# auth params
# TODO UNUSED
var username: String
var password: String
var email: String

var socket: WebSocketPeer
var last_state := WebSocketPeer.STATE_CLOSED
var connected: bool = false

func _ready() -> void:
	set_process(false)
	
func isConnected() -> bool:
	return connected

func connectToServer():
	socket = WebSocketPeer.new()
	
	var url = 'ws://localhost:8080/game' 
	var opts = null
	#var url = 'ws://playrealm.net:8080/game'
	
	#if OS.get_name() == "Web":
	#if true:
	#	url = 'wss://playrealm.net:443/game'
	#	opts = TLSOptions.client_unsafe()
	
	print("%s %s" % [OS.get_name(), url])
	
	var err = socket.connect_to_url(url, opts)
	
	if err != OK: print("Unable to connect")
	else: set_process(true)

func onReceive(_op: int, _state: Variant) -> void:
	pass # you should override this method in the derived class
	
func _process(_delta):
	if !socket: return
	
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()

	var state := socket.get_ready_state()

	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			connection_closed.emit()
			var code = socket.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false)
			connected = false
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		#message_received.emit(get_message())
		var data = socket.get_packet().get_string_from_utf8()
		var json = JSON.new()
		var err = json.parse(data)
		if err == OK: _onReceive(json.data)
	
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
