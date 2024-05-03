extends Node3D

class_name PlayScene

@onready var cp: CellPositions = $CellPositions #get_node("CellPositions")
@onready var reference_piece: MeshInstance3D = $piece # $die
@onready var nc: GooseNakamaClient = $Ui.nc

var players: Dictionary = {}
# piece (MeshInstance3D)
# cell_no (int)
# cell_destination_no (int)
# color (Color)

var current_player_user_id: String = ""

var _queued_piece_move: Array = []

const LAST_CELL_NO: int = 63

func _ready():
	cp.set_die_face(randi_range(1, 6))
	nc.play_scene = self

func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE: get_tree().quit()
			elif event.keycode == KEY_SPACE: nc.play()
	
func _start_moving_piece(destination_cell_no: int) -> void:
	var p = players[current_player_user_id]
	p.cell_destination_no = destination_cell_no
	p.cell_no += 1
	cp.position_animation_finished.connect(_resume_moving_piece)
	cp.animate_to_position(p.piece, p.cell_no)

func _resume_moving_piece() -> void:
	var p = players[current_player_user_id]
	if p.cell_no == p.cell_destination_no:
		cp.position_animation_finished.disconnect(_resume_moving_piece)
		return _piece_moved(0)
	p.cell_no += 1
	cp.animate_to_position(p.piece, p.cell_no)


func _create_piece(user_id: String) -> MeshInstance3D:
	var piece: MeshInstance3D = reference_piece.duplicate()
	add_child(piece)
	piece.visible = true
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf(), 1.0)
	piece.material_override = mat
	cp.animate_to_position(piece, 0)
	#piece.name = 'piece_%s' % user_id
	return piece

#func next_to_play(user_ids: Array[String]) -> void:
func next_to_play(user_ids):
	#print(user_id)
	for user_id in user_ids:
		if !players.has(user_id):
			_add_player(user_id)
	current_player_user_id = user_ids[0]
	
func _add_player(user_id):
	players[user_id] = {
		'piece': _create_piece(user_id),
		'cell_no': 0,
		'cell_destination_no': 0,
	}

func users_changed(user_ids):
	pass # TODO is this needed?
	#print(user_ids)

func apply_dice_roll(value: int) -> void:
	cp.rolling_animation_finished.connect(_piece_moved, CONNECT_ONE_SHOT)
	cp.roll_die(value)

func piece_moved(user_id: String, piece_no: int) -> void:
	_queued_piece_move.push_back([user_id, piece_no])
	
func _piece_moved(face_no):
	print('_piece_moved (%d moves to address)' % _queued_piece_move.size())
	if _queued_piece_move.size() > 0:
		var piece_move = _queued_piece_move.pop_front()
		var user_id = piece_move[0]
		var piece_no = piece_move[1]
		var piece = players[user_id].piece # TODO
		_start_moving_piece(piece_no)
