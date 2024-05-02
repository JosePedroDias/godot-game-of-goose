extends GenericNakamaClient

class_name GooseNakamaClient

@export var label: Label
var play_scene: PlayScene

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

func go():	
	super.go()

func get_user_id() -> String:
	return _session.user_id
	
func on_receive(op: int, data) -> void:
	print(op, ' | ', data)
	
	if !play_scene:
		print('no play scene!')
		return
	
	match op:
		OPCODE.NEXT_TO_PLAY:
			print("NEXT_TO_PLAY: ", data[0])
			play_scene.next_to_play__(data[0])
		OPCODE.USERS_CHANGED:
			print("USERS_CHANGED: ", data)
			play_scene.users_changed(data)
		OPCODE.PIECE_MOVED:
			print("PIECE_MOVED: ", data.user_id, data.cell_no)
			play_scene.piece_moved(data.user_id, data.cell_no)
		OPCODE.DICE_ROLL:
			print("DICE_ROLL", data)
			play_scene.apply_dice_roll(data)

func play():
	await _send(OPCODE.ROLL_DICE, {})
