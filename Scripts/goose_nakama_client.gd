extends GenericNakamaClient

class_name GooseNakamaClient

var play_scene: PlayScene

var out: OverlayOutput

const OPCODE = {
	# server to client
	OPPONENT_LEFT = 102,
	REJECTED = 103,
	DONE = 104,
	FEEDBACK = 105,
	
	NEXT_TO_PLAY = 106,
	USERS_CHANGED = 107,
	PIECE_MOVED = 108,
	DICE_ROLL = 109,
	
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
		OPCODE.FEEDBACK:
			out.log(data)
		OPCODE.NEXT_TO_PLAY:
			#out.log("NEXT_TO_PLAY: %s" % JSON.stringify(data))
			play_scene.next_to_play(data)
		#OPCODE.USERS_CHANGED:
		#	out.log("USERS_CHANGED: %s" + JSON.stringify(data))
		#	play_scene.users_changed(data)
		OPCODE.PIECE_MOVED:
			#out.log("PIECE_MOVED: %s, %d" % [data.user_id,data.cell_no])
			play_scene.piece_moved(data.user_id, data.cell_no)
		OPCODE.DICE_ROLL:
			#out.log("DICE_ROLL: %d" % data)
			play_scene.apply_dice_roll(data)

func roll_dice():
	await _send(OPCODE.ROLL_DICE, {})
