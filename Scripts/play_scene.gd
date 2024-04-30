extends Node3D

@onready var cp: CellPositions = $CellPositions #get_node("CellPositions")
@onready var reference_piece: MeshInstance3D = $piece # $die

var pieces: Array[MeshInstance3D] = []
var next_to_play: Array[int] = []
var player_cell_index: Array[int] = []

#var current_cell_no: int = -1
const last_cell_no: int = 63

func _ready():
	cp.set_die_face(randi_range(1, 6))
	_create_piece()
	_create_piece()
	_create_piece()
	
	#print( _current_player() )

func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE: get_tree().quit()
			elif event.keycode == KEY_1: cp.roll_die(1)
			elif event.keycode == KEY_2: cp.roll_die(2)
			elif event.keycode == KEY_3: cp.roll_die(3)
			elif event.keycode == KEY_4: cp.roll_die(4)
			elif event.keycode == KEY_5: cp.roll_die(5)
			elif event.keycode == KEY_6: cp.roll_die(6)
			elif event.keycode == KEY_7:
				start_next_player_round()
			#elif event.keycode == KEY_9: traverse_the_board()

func start_next_player_round() -> void:
	var player_index = _next_player()
	var die_value = randi_range(1, 6)
	cp.rolling_animation_finished.connect(_resume_player_round_after_rolling_die)
	cp.roll_die(die_value)
	
func _resume_player_round_after_rolling_die(die_value) -> void:
	var player_index = _current_player()
	cp.rolling_animation_finished.disconnect(_resume_player_round_after_rolling_die)
	var current_cell_no = player_cell_index[player_index]
	current_cell_no += die_value
	player_cell_index[player_index] = current_cell_no
	cp.animate_to_position(pieces[player_index], current_cell_no) # TODO animate intermediate step

#func _piece_movement_done() -> void:
	#_traverse_the_board()
#
#func traverse_the_board() -> void:
	#cp.animation_finished.connect(_piece_movement_done)
	#_traverse_the_board()
#
#func _traverse_the_board() -> void:
	#if current_cell_no == last_cell_no:
		#cp.animation_finished.disconnect(_piece_movement_done)
		#print("all done")
	#else:
		#current_cell_no += 1
		#print("step %d" % current_cell_no)
		#cp.animate_to_position(pieces[0], current_cell_no)

func _create_piece() -> void:
	var piece: MeshInstance3D = reference_piece.duplicate()
	add_child(piece)

	piece.visible = true
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf(), 1.0)
	piece.material_override = mat
	
	cp.animate_to_position(piece, 0)#pieces.size())
	
	pieces.push_back(piece)
	next_to_play.push_back(next_to_play.size())
	player_cell_index.push_back(0)

func _next_player() -> int:
	var result = next_to_play.pop_front()
	next_to_play.push_back(result)
	return result

func _current_player() -> int:
	return next_to_play[-1]
