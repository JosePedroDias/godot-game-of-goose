extends Node

class_name CellPositions

@onready var play_scene = $".."

@export var die: MeshInstance3D
var children_positions: Array[Node3D] = []

var die_quats: Array[Quaternion] = []
var cell_occupants: Array[Array] = []

signal position_animation_finished
signal rolling_animation_finished

var move_piece_duration = 0.3 #0.7
var roll_die_step_duration = 0.5

const RAD_90 = 0.5 * PI
const RAD_180 = PI
const RAD_360 = 2.0 * PI

const RAD_TO_DEG = 180.0 / PI

const PIECE_RADIUS = 0.2

func _ready():
	# populates children_positions
	var children = get_children()
	for n:Node in children:
		if n.name != 'board':
			children_positions.push_back(n)
	
	# populates die_quats
	die_quats.push_back( Quaternion(Vector3(0.0, 0.0, 1.0), RAD_90).normalized() ) #0 (1) OK
	die_quats.push_back( Quaternion(Vector3(1.0, 0.0, 0.0), -RAD_90).normalized() ) #1 (2) OK
	die_quats.push_back( Quaternion().normalized() ) #2 (3) OK
	die_quats.push_back( Quaternion(Vector3(1.0, 0.0, 0.0), RAD_180).normalized() ) #3 (4) OK
	die_quats.push_back( Quaternion(Vector3(1.0, 0.0, 0.0), RAD_90).normalized() ) #4 (5) OK
	die_quats.push_back( Quaternion(Vector3(0.0, 0.0, 1.0), -RAD_90).normalized() ) #5 (6) OK
	
	# populate cell_occupants
	for i in range(play_scene.LAST_CELL_NO + 1):
		cell_occupants.push_back([])

func get_nth_marker(cell_nr: int) -> Node3D:
	var is_valid = cell_nr >= 0 && cell_nr < children_positions.size()
	if !is_valid:
		print('get_nth_marker received wrong index')
		cell_nr = 0
	return children_positions[cell_nr]
	
func animate_to_position(piece: Node3D, cell_nr: int) -> void:
	# update cell occupants
	for i in range(play_scene.LAST_CELL_NO + 1):
		var items2 = cell_occupants[i]
		var found_idx = items2.find(piece)
		if found_idx != -1: items2.remove_at(found_idx)
	var items = cell_occupants[cell_nr]
	items.push_back(piece)
	
	# get reference position and orientation from makers stored in children_positions
	var node = get_nth_marker(cell_nr)
	var pos = node.position
	var q = node.quaternion
	
	var multiple_occupants = items.size() > 1
	if multiple_occupants:
		var i = 0
		var d_angle = RAD_360 / items.size()
		for item in items:
			var angle = i * d_angle
			var pos2 = Vector3(pos)
			pos2 += Vector3(
				PIECE_RADIUS * cos(angle),
				0,
				PIECE_RADIUS * sin(angle)
			)
			var tween0 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
			tween0.tween_property(item, "position", pos2, move_piece_duration)
			i += 1
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	if !multiple_occupants:
		tween.tween_property(piece, "position", pos, move_piece_duration)
	tween.tween_property(piece, "quaternion", q, move_piece_duration)
	tween.chain().tween_callback(func(): position_animation_finished.emit())

func _random_quaternion() -> Quaternion:
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0)
	var z = randf_range(-1.0, 1.0)
	var w = randf_range(-1.0, 1.0)
	return Quaternion(x, y, z, w).normalized()

func _get_face_quaternion(face_no: int) -> Quaternion:
	if face_no < 1 || face_no > 6:
		print('wrong face number. expect 1-6')
		return die.quaternion
	return die_quats[face_no - 1]

func set_die_face(face_no: int) -> void:
	die.quaternion = _get_face_quaternion(face_no)

func roll_die(face_no: int) -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(die, "quaternion", _random_quaternion(),          roll_die_step_duration)
	tween.tween_property(die, "quaternion", _get_face_quaternion(face_no), roll_die_step_duration)
	tween.tween_callback(func(): rolling_animation_finished.emit())
