extends Node3D

class_name PlayScene

@onready var cp: CellPositions = $CellPositions #get_node("CellPositions")
@onready var reference_piece: MeshInstance3D = $piece # $die
@onready var nc: GooseNakamaClient = $Ui.nc

var pieces: Array[MeshInstance3D] = []
var next_to_play: Array[int] = []
var player_cell_index: Array[int] = []
var player_cell_destination_index: Array[int] = []

const LAST_CELL_NO: int = 63

func _ready():
	cp.set_die_face(randi_range(1, 6))
	nc.play_scene = self
	#_create_piece()
	#_create_piece()
	#_create_piece()

func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE: get_tree().quit()
			#elif event.keycode == KEY_SPACE: start_next_player_round()
			elif event.keycode == KEY_SPACE: nc.play()

func start_next_player_round() -> void:
	var player_index = _next_player()
	var current_cell_no = player_cell_index[player_index]
	
	if current_cell_no == LAST_CELL_NO:
		print('nowhere to move to. skip')
		return
	
	var die_value = randi_range(1, 6)
	cp.rolling_animation_finished.connect(_resume_player_round_after_rolling_die)
	cp.roll_die(die_value)
	
func _resume_player_round_after_rolling_die(die_value) -> void:
	var player_index = _current_player()
	cp.rolling_animation_finished.disconnect(_resume_player_round_after_rolling_die)
	var current_cell_no = player_cell_index[player_index]
	player_cell_index[player_index] = clamp(current_cell_no + 1, 0, LAST_CELL_NO)
	player_cell_destination_index[player_index] = clamp(current_cell_no + die_value, 0, LAST_CELL_NO)
	cp.animate_to_position(pieces[player_index], current_cell_no + 1)
	cp.position_animation_finished.connect(_resume_player_round_after_moving_a_cell)

func _resume_player_round_after_moving_a_cell() -> void:
	var player_index = _current_player()
	var current_cell_no = player_cell_index[player_index]
	var destination_cell_no = player_cell_destination_index[player_index]
	
	if destination_cell_no == current_cell_no:
		cp.rolling_animation_finished.disconnect(_resume_player_round_after_moving_a_cell)
	else:
		player_cell_index[player_index] = current_cell_no + 1
		cp.animate_to_position(pieces[player_index], current_cell_no + 1)

func _create_piece() -> void:
	var piece: MeshInstance3D = reference_piece.duplicate()
	add_child(piece)

	piece.visible = true
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf(), 1.0)
	piece.material_override = mat
	
	cp.animate_to_position(piece, 0)#pieces.size())
	
	var player_idx = next_to_play.size()
	piece.name = 'piece_%s' % player_idx
	
	pieces.push_back(piece)
	next_to_play.push_back(player_idx)
	player_cell_index.push_back(0)
	player_cell_destination_index.push_back(0)

func _next_player() -> int:
	var result = next_to_play.pop_front()
	next_to_play.push_back(result)
	return result

func _current_player() -> int:
	return next_to_play[-1]

func next_to_play__(user_id: String) -> void:
	print(user_id)

func users_changed(user_ids):
#func users_changed(user_ids: Array[String]) -> void:
	print(user_ids)

func piece_moved(user_id: String, piece_no: int) -> void:
	print(user_id, ',', piece_no)
	
func apply_dice_roll(value: int) -> void:
	print(value)
