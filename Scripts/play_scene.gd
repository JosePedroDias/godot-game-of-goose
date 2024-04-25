extends Node3D

@onready var cp: CellPositions = $CellPositions #get_node("CellPositions")
@onready var piece: MeshInstance3D = $die# $piece

var current_cell_no: int = -1
const last_cell_no: int = 63

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
			elif event.keycode == KEY_1:
				#cp.animation_finished.connect(_done, CONNECT_ONE_SHOT)
				cp.animate_to_position(piece, 0)
			elif event.keycode == KEY_2:
				#cp.animate_to_position(piece, 0)
				traverse_the_board()

func _piece_movement_done():
	_traverse_the_board()

func traverse_the_board():
	cp.animation_finished.connect(_piece_movement_done)
	_traverse_the_board()

func _traverse_the_board():
	if current_cell_no == last_cell_no:
		cp.animation_finished.disconnect(_piece_movement_done)
		print("all done")
	else:
		current_cell_no += 1
		print("step %d" % current_cell_no)
		cp.animate_to_position(piece, current_cell_no)
