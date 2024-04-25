extends Node

class_name CellPositions

@export var die: MeshInstance3D
var children_positions: Array[Node3D] = []

var die_quats: Array[Quaternion] = []

signal animation_finished

var move_piece_duration = 0.4 #0.7
var roll_die_step_duration = 0.5

const RAD_90 = 0.5 * PI
const RAD_180 = PI

func _ready():
	var children = get_children()
	for n:Node in children:
		if n.name != 'board':
			children_positions.push_back(n)
	
	die_quats.push_back( Quaternion(Vector3(0.0, 0.0, 1.0), RAD_90).normalized() ) #0 (1) OK
	die_quats.push_back( Quaternion(Vector3(1.0, 0.0, 0.0), -RAD_90).normalized() ) #1 (2) OK
	die_quats.push_back( Quaternion().normalized() ) #2 (3) OK
	die_quats.push_back( Quaternion(Vector3(1.0, 0.0, 0.0), RAD_180).normalized() ) #3 (4) OK
	die_quats.push_back( Quaternion(Vector3(1.0, 0.0, 0.0), RAD_90).normalized() ) #4 (5) OK
	die_quats.push_back( Quaternion(Vector3(0.0, 0.0, 1.0), -RAD_90).normalized() ) #5 (6) OK

func get_nth_marker(cell_nr: int) -> Node3D:
	var is_valid = cell_nr >= 0 && cell_nr < children_positions.size()
	if !is_valid:
		print('get_nth_marker received wrong index')
		cell_nr = 0
	return children_positions[cell_nr]
	
func animate_to_position(piece: Node3D, cell_nr: int) -> void:
	var node = get_nth_marker(cell_nr)
	
	var pos = node.position
	var q = node.quaternion
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(piece, "position", pos, move_piece_duration)
	tween.tween_property(piece, "quaternion", q, move_piece_duration)
	tween.chain().tween_callback(func(): animation_finished.emit())

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
	tween.tween_property(die, "quaternion", _random_quaternion(),          roll_die_step_duration)
	tween.tween_property(die, "quaternion", _get_face_quaternion(face_no), roll_die_step_duration)
