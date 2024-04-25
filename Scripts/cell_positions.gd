extends Node

class_name CellPositions

var children_positions: Array[Node3D] = []

signal animation_finished

var anim_duration = 0.7

func _ready():
	var children = get_children()
	for n:Node in children:
		if n.name != 'board':
			children_positions.push_back(n)

func get_nth_marker(cell_nr: int) -> Node3D:
	var is_valid = cell_nr >= 0 && cell_nr < children_positions.size()
	if !is_valid:
		print('get_nth_marker received wrong index')
		cell_nr = 0
	return children_positions[cell_nr]
	
func animate_to_position(piece: Node3D, cell_nr: int):
	var node = get_nth_marker(cell_nr)
	
	var pos = node.position
	var q = node.quaternion
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(piece, "position", pos, anim_duration)
	tween.tween_property(piece, "quaternion", q, anim_duration)
	tween.chain().tween_callback(func(): animation_finished.emit())
