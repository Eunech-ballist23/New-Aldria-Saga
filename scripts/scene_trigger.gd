extends Area2D

# This allows you to select the next level file in the Godot Editor
@export_file("*.tscn") var connected_scene: String

func _on_body_entered(body: Node2D) -> void:
	# Only trigger if the Player enters
	if body.is_in_group("player"):
		if connected_scene == "":
			print("Warning: No scene assigned to this trigger!")
			return
			
		# Change the scene to the one selected in the Inspector
		get_tree().call_deferred("change_scene_to_file", connected_scene)
