extends GenericServerClient

class_name GooseClient

var play_scene: PlayScene

var out: OverlayOutput

var sessionId: String = ""

const OPCODE = {
	# server to client
	GAME_OVER = 100,
	SLEEP = 101,
	YOUR_SESSION_ID = 102,
	REJECTED = 103,
	FEEDBACK = 105,
	NEXT_TO_PLAY = 106,
	PLAYERS_CHANGED = 107,
	PIECE_MOVED = 108,
	ROLL_DICE_OUTCOME = 109,
	
	# client to server
	ROLL_DICE = 200,
}

func _ready():
	out = get_parent().out

func connectToServer():	
	super.connectToServer()

func getSessionId() -> String:
	return sessionId

func onReceive(op: int, data) -> void:
	out._print('%d | %s' % [op, data])
	
	if !play_scene:
		print('no play scene!')
		return
	
	match op:
		OPCODE.SLEEP:
			play_scene.sleep(data)
		OPCODE.YOUR_SESSION_ID:
			sessionId = data
		OPCODE.GAME_OVER:
			play_scene.game_over(data)
		OPCODE.REJECTED:
			play_scene.feedback('rejected move!')
		OPCODE.FEEDBACK:
			play_scene.feedback(data)
		OPCODE.NEXT_TO_PLAY:
			play_scene.next_to_play(data)
		OPCODE.PLAYERS_CHANGED:
			play_scene.users_changed(data)
		OPCODE.PIECE_MOVED:
			play_scene.piece_moved(data.sessionId, data.cellNo)
		OPCODE.ROLL_DICE_OUTCOME:
			play_scene.roll_dice_outcome(data)
		_:
			print('unsupported opcode received:', op)

func roll_dice():
	_send(OPCODE.ROLL_DICE, {})
