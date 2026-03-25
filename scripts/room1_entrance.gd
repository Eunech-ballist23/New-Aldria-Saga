extends Area2D

# This creates a slot in the Inspector to pick your level file
@export_file("*.tscn") var target_level_path: String

func _on_body_entered(body):
	# Check if the colliding object is the player
	if body.is_in_group("player"):
		if target_level_path == "":
			print("Warning: No target level set in the Inspector for this portal!")
			return
			
		if FileAccess.file_exists(target_level_path):
			AudioController.portalSF()
			# Change to the level you selected in the Inspector
			get_tree().call_deferred("change_scene_to_file", target_level_path)
		else:
			print("Error: Scene file not found at: ", target_level_path)
