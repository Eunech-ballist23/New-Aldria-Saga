extends Node2D

# 1. Configuration variables
@export var enemy_scenes: Array[PackedScene] 
@export var spawn_marker: Marker2D 
@export var spawn_range: float = 50.0 
@export var max_enemies: int = 6

# --- NEW PERMANENCE LOGIC ---
@export var total_max_lifetime_spawns: int = 10  # Total enemies this spawner can EVER create
var total_spawned_so_far: int = 0
var is_exhausted: bool = false
# ----------------------------

@onready var timer = $Timer

func _on_timer_timeout() -> void:
	# If we have reached the lifetime limit, stop the timer and exit 
	if is_exhausted:
		timer.stop()
		return

	# 2. Check Population Limit 
	var enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if enemy_count >= max_enemies:
		return 
	
	if enemy_scenes.is_empty():
		return
	
	# 3. Create the Enemy 
	var enemy_scene = enemy_scenes.pick_random()
	var enemy = enemy_scene.instantiate()
	
	# 4. Set Position 
	var anchor_pos = global_position 
	if spawn_marker:
		anchor_pos = spawn_marker.global_position
	
	var offset = Vector2(randf_range(-spawn_range, spawn_range), randf_range(-spawn_range, spawn_range))
	enemy.global_position = anchor_pos + offset
	
	# 5. Add to the World 
	get_tree().current_scene.add_child(enemy)

	# --- TRACK SPAWN COUNT ---
	total_spawned_so_far += 1
	if total_spawned_so_far >= total_max_lifetime_spawns:
		is_exhausted = true
		print("Spawner at ", global_position, " is now empty forever.")
