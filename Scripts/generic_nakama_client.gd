extends Node

class_name GenericNakamaClient

# nakama config
@export var host: String = "localhost"
@export var port: int = 7350
@export var key: String = "defaultkey"
@export var secure: bool = false
@export var timeout: int = 10
@export var debug: bool = true
@export var game_rpc: String = "goose_match"

# nakama internal instances
var _client: NakamaClient
var _socket: NakamaSocket
var _session: NakamaSession
var _match: NakamaRTAPI.Match

# auth params
var email: String
var password: String
var username: String

func go():
	#print('email:%s, password:%s, username:%s' % [email, password, username])
	
	_client = Nakama.create_client(
		key,
		host,
		port,
		'https' if secure else 'http',
		timeout,
		NakamaLogger.LOG_LEVEL.DEBUG if debug else NakamaLogger.LOG_LEVEL.NONE
	)
	
	
	#if !debug:
	#	Nakama.logger._level = NakamaLogger.LOG_LEVEL.NONE
	#_client.timeout = timeout
	#print('client: ', _client)
	
	_session = await _client.authenticate_email_async(email, password, username)
	if _session.is_exception():
		print('auth failed!!', _session)
		return
	#print('session: ', _session)
	
	_socket = Nakama.create_socket_from(_client)
	
	#_socket = Nakama.create_socket(
	#	host,
	#	port,
	#	'wss' if secure else 'ws',
	#)
	
	_socket.connected.connect(_on_socket_connected)
	_socket.closed.connect(_on_socket_closed)
	_socket.received_error.connect(_on_socket_error)
	
	await _socket.connect_async(_session)
	
	var rpc_resp : NakamaAPI.ApiRpc = await _socket.rpc_async(
		game_rpc,
		JSON.stringify({ fast = false })
	)
	if rpc_resp.is_exception():
		print("An error occurred: %s" % rpc_resp)
		return
	else:
		var o = JSON.parse_string(rpc_resp.payload) #;print(o)
		var match_id = o["matchIds"][0] #;print('match_id: ', match_id)
		_match = await _socket.join_match_async(match_id) #;print('match: ', _match)
		_socket.received_match_state.connect(_on_match_state)

func _on_socket_connected():
	print("Socket connected.")

func _on_socket_closed():
	print("Socket closed.")

func _on_socket_error(err):
	printerr("Socket error %s" % err)

func on_receive(_op: int, _state) -> void:
	pass # you should override this method in the derived class
	
func _on_match_state(o: NakamaRTAPI.MatchData):
	var op = o.op_code
	var state = JSON.parse_string(o.data) if o.data && o.data != null else null
	on_receive(op, state)

func _send(op, state):
	if !_socket: print('not ready to play yet'); return
	await _socket.send_match_state_async(_match.match_id, op, JSON.stringify(state))

