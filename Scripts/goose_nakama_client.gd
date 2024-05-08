extends GenericNakamaClient

class_name GooseNakamaClient

var play_scene: PlayScene

var out: OverlayOutput

const OPCODE = {
	# server to client
	GAME_OVER = 100,
	SLEEP = 101,
	REJECTED = 103,
	FEEDBACK = 105,
	NEXT_TO_PLAY = 106,
	USERS_CHANGED = 107,
	PIECE_MOVED = 108,
	ROLL_DICE_OUTCOME = 109,
	
	# client to server
	ROLL_DICE = 200,
}

func _ready():
	out = get_parent().out

func go():	
	super.go()

func get_user_id() -> String:
	return _session.user_id

func on_receive(op: int, data) -> void:
	out._print('%d | %s' % [op, data])
	
	if !play_scene:
		print('no play scene!')
		return
	
	match op:
		OPCODE.SLEEP:
			play_scene.sleep(data)
		OPCODE.GAME_OVER:
			play_scene.game_over(data)
		OPCODE.REJECTED:
			play_scene.feedback('rejected move!')
		OPCODE.FEEDBACK:
			play_scene.feedback(data)
		OPCODE.NEXT_TO_PLAY:
			play_scene.next_to_play(data)
		OPCODE.USERS_CHANGED:
			play_scene.users_changed(data)
		OPCODE.PIECE_MOVED:
			play_scene.piece_moved(data.user_id, data.cell_no)
		OPCODE.ROLL_DICE_OUTCOME:
			play_scene.roll_dice_outcome(data)
		_:
			print('unsupported opcode received:', op)

func roll_dice():
	await _send(OPCODE.ROLL_DICE, {})
