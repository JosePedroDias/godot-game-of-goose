extends Node

var nth: int = -1
var timer: SceneTreeTimer

func _ready():
	timer = get_tree().create_timer(.3)
	nth = await get_incremental_number() % 2
	print('nth: %d' % nth)
		
func get_incremental_number():
	var save_path = "user://incremental.tres"
	
	var store_value = func(val): 
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_64(val)
		file.flush()
		file.close()
	
	var read_value = func():
		await timer.timeout
		if FileAccess.file_exists(save_path):
			#await .timeout # Wait for val to be saved
			var file = FileAccess.open(save_path, FileAccess.READ)
			var value = file.get_64()
			file.close()
			return value
		return 0 
	
	var value = await read_value.call()
	store_value.call(value + 1)
	return value
