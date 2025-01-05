extends Node3D

class_name PlayScene

const CMD_NEXT_TO_PLAY      = 1
const CMD_USERS_CHANGED     = 2
const CMD_ROLL_DICE_OUTCOME = 3
const CMD_PIECE_MOVED       = 4
const CMD_FEEDBACK          = 5
const CMD_SLEEP             = 6
const CMD_GAME_OVER         = 7

@onready var cp: CellPositions = $CellPositions #get_node("CellPositions")
@onready var reference_piece: MeshInstance3D = $piece # $die
@onready var nc: GooseClient = $Ui.nc
@onready var out: OverlayOutput = %out

var players: Dictionary = {}
# piece (MeshInstance3D)
# cell_no (int)
# cell_destination_no (int)
# username (String)
# color (Color) ***

var current_player_user_id: String = ""

var _commands_queue: Array = []

const LAST_CELL_NO: int = 63

func _ready():
	cp.set_die_face(randi_range(1, 6))
	nc.play_scene = self
	
	await Incremental.timer.timeout
	_place_window()

func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE: get_tree().quit()
			elif event.keycode == KEY_BACKSLASH: out.toggle_visibility()
			elif event.keycode == KEY_SPACE: nc.roll_dice()
			elif event.keycode == KEY_D: breakpoint

func _create_piece(_user_id: String) -> MeshInstance3D:
	var piece: MeshInstance3D = reference_piece.duplicate()
	add_child(piece)
	piece.visible = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf(), 1.0)
	piece.material_override = mat
	cp.animate_to_position(piece, 0, 1)
	#piece.name = 'piece_%s' % user_id
	return piece

#################

var _handle_commands_occupied = false

func _pl(n: int) -> String:
	return '' if n == 1 else 's'

func _usernames_from_user_ids(user_ids):
	var result = []
	for user_id in user_ids:
		result.push_back( players[user_id].username )
	return result

func _a(label, user_ids):
	if user_ids.size() > 0: out.log(label % [_pl(user_ids.size()), ', '.join(_usernames_from_user_ids(user_ids))])

func _handle_commands():
	if _handle_commands_occupied: return
	_handle_commands_occupied = true
	while _commands_queue.size() > 0:
		var cmd: Array = _commands_queue.pop_front()
		#print(cmd)
		var cmd_name = cmd[0]
		var arg0 = null if cmd.size() < 2 else cmd[1]
		var arg1 = null if cmd.size() < 3 else cmd[2]
		
		match cmd_name:
			CMD_USERS_CHANGED:
				var users_details = arg0
				var new_user_ids = []
				var missing_user_ids = players.keys()
				
				var tmp_i = missing_user_ids.find(nc.getSessionId())
				if tmp_i != -1: missing_user_ids.remove_at(tmp_i)
				
				for user_id in users_details:
					var user_details = users_details[user_id]
					var idx = missing_user_ids.find(user_id)
					if idx != -1:
						missing_user_ids.remove_at(idx)
					else:
						if !players.has(user_id): _add_player(user_id, user_details.username)
						if user_id != nc.getSessionId(): new_user_ids.push_back(user_id)
				_a('new player%s: %s', new_user_ids)
				_a('player%s left: %s', missing_user_ids)
			CMD_NEXT_TO_PLAY:
				var user_ids = arg0
				current_player_user_id = user_ids[0]
				var current_player_username = players[current_player_user_id].username
				if current_player_user_id == nc.getSessionId(): out.log("our time to play")
				else: out.log("it's %s time to play" % current_player_username)
			CMD_ROLL_DICE_OUTCOME:
				var value = arg0
				out.log('the die landed on %d' % value)
				await cp.roll_die(value)
			CMD_PIECE_MOVED:
				var user_id  = arg0
				var desired_cell_no = arg1
				out._print("piece_moved('%s', %d)" % [user_id, desired_cell_no])
				var player = players[user_id]
				var piece = player.piece
				var current_cell_no = player.cell_no
				await cp.animate_to_position(piece, desired_cell_no, current_cell_no)
				player.cell_no = desired_cell_no
			CMD_FEEDBACK:
				var msg = arg0
				out.log('feedback: %s' % msg)
			CMD_SLEEP:
				var ms = arg0
				var secs = 0.001 * ms
				out.log('sleeping for: %.1f secs' % secs)
				await get_tree().create_timer(secs).timeout
			CMD_GAME_OVER:
				var sessionId = arg0
				if len(sessionId) > 0:
					var winner_username = players[sessionId].username
					out.log('%s won the game!' % winner_username)
				else:
					out.log('game over :|')
			_:
				print('unsupported command: ' + cmd_name)
	_handle_commands_occupied = false

#################

# INCOMING OPCODE
func sleep(ms: int) -> void:
	_commands_queue.push_back([CMD_SLEEP, ms])
	_handle_commands()

# INCOMING OPCODE
func game_over(user_id: String) -> void:
	_commands_queue.push_back([CMD_GAME_OVER, user_id])
	_handle_commands()

func feedback(msg: String) -> void:
	_commands_queue.push_back([CMD_FEEDBACK, msg])
	_handle_commands()

# INCOMING OPCODE
func next_to_play(user_ids):
	_commands_queue.push_back([CMD_NEXT_TO_PLAY, user_ids])
	_handle_commands()

# INCOMING OPCODE
func users_changed(users_details):
	_commands_queue.push_back([CMD_USERS_CHANGED, users_details])
	_handle_commands()

# INCOMING OPCODE
func roll_dice_outcome(value: int) -> void:
	_commands_queue.push_back([CMD_ROLL_DICE_OUTCOME, value])
	_handle_commands()

# INCOMING OPCODE
func piece_moved(user_id: String, piece_no: int) -> void:
	_commands_queue.push_back([CMD_PIECE_MOVED, user_id, piece_no])
	_handle_commands()

#################

func _add_player(user_id: String, username: String):
	players[user_id] = {
		piece = _create_piece(user_id),
		cell_no = 0,
		cell_destination_no = 0,
		username = username,
	}

func _place_window():
	var vp = DisplayServer.screen_get_size()
	get_window().size = Vector2(0.40*vp.x, 0.40*vp.y)
	if Incremental.nth == 0:
		get_window().position = Vector2(0.05*vp.x, 0.30*vp.y)
	else:
		get_window().position = Vector2(0.55*vp.x, 0.30*vp.y)
