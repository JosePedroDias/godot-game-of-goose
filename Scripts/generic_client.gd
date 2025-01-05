extends Node

class_name GenericServerClient

var username: String
var password: String
var email: String
var connected: bool = false

func _ready() -> void:
	set_process(false)
	
func isConnected() -> bool:
	return connected

func connectToServer():
	var url = 'ws://localhost:8080/game'
	var inWeb = OS.has_feature('web')
	
	if inWeb:
		url = 'wss://playrealm.net/game'
		JavaScriptBridge.eval("diyws('" + url + "')")
		connected = true
		set_process(true)

func onReceive(_op: int, _state: Variant) -> void:
	pass # you should override this method in the derived class
	
func _process(_delta):
	if !connected: return
	while JavaScriptBridge.eval('diyHasMessages()'):
		var str = JavaScriptBridge.eval('diyGetNextMessage()')
		_onReceive(str)
	
func _onReceive(str: String):
	var j := JSON.new()
	var e = j.parse(str)
	if e == OK:
		var op = j.data.op
		var state = null
		if j.data.payload && j.data.payload != null:
			var j2 := JSON.new()
			var e2 = j2.parse(j.data.payload)
			if e2 == OK: state = j2.data
		onReceive(op, state)

func _send(op, state):
	var msg = 'null'
	if state != null: msg = JSON.stringify(state)
	JavaScriptBridge.eval('diySend(' + str(op) + ',\'' + msg + '\')')
