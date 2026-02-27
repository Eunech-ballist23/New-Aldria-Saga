extends Node2D

# 1. Configuration variables
@export var enemy_scenes: Array[PackedScene] 
@export var spawn_marker: Marker2D # The "Best Option": Drag your Marker here in Inspector
@export var spawn_range: float = 50.0 # Small range keeps them near the marker
@export var max_enemies: int = 6

@onready var timer = $Timer

func _on_timer_timeout() -> void:
	# 2. Check Population Limit
	# Note: Ensure enemies are added to the "enemies" group in their own scenes
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if enemy_count >= max_enemies:
		return 
	
	if enemy_scenes.is_empty():
		return
	
	# 3. Create the Enemy
	var enemy_scene = enemy_scenes.pick_random()
	var enemy = enemy_scene.instantiate()
	
	# 4. Set Position (Using the Exported Marker)
	var anchor_pos = global_position # Fallback to spawner position
	if spawn_marker:
		anchor_pos = spawn_marker.global_position
	else:
		print("Warning: No Spawn Marker assigned to ", name)
	
	# Apply a small random offset around the anchor
	var offset = Vector2(randf_range(-spawn_range, spawn_range), randf_range(-spawn_range, spawn_range))
	enemy.global_position = anchor_pos + offset
	
	# 5. Add to the World
	get_tree().current_scene.add_child(enemy)
