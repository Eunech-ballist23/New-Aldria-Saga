extends Area2D

# The base path of your levels
const FILE_BEGIN = "res://scenes/Game_Level/room_" 

func _on_body_entered(body):
	if body.is_in_group("player"):
		var current_scene_path = get_tree().current_scene.scene_file_path
		
		var stage_number = current_scene_path.replace(FILE_BEGIN, "").replace(".tscn", "")
		var next_level_number = stage_number.to_int() + 1
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"	
		
		if FileAccess.file_exists(next_level_path):
			# Use call_deferred to avoid the physics callback error
			get_tree().call_deferred("change_scene_to_file", next_level_path)
		else:
			print("Finished! No more levels found at: ", next_level_path)
