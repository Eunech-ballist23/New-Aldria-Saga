extends Node2D

@onready var player = $Player
@onready var health_bar = $HUD/HealthBar
@onready var game_over_ui = $GameOverScreen
@onready var win_screen = $WinScreen
@onready var skeleton_king = $SkeletonKing

# -> Drag your TileMap node here if the name is different! <-
@onready var tilemap = $Grasses_and_terrains 

func _ready() -> void:
	
	# --- 1. EXISTING SIGNAL CONNECTIONS ---
	if has_node("Player"):
		$Player.player_died.connect(_on_player_died)
	else:
		print("Error: Player node not found!")
	
	if player and health_bar:
		player.health_changed.connect(health_bar.update_health)

	if skeleton_king:
		skeleton_king.boss_defeated.connect(_on_boss_defeated)

	# --- 2. AUTOMATIC CAMERA LIMITS (GODOT 4) ---
	if player and tilemap:
		# Get the grid boundaries of your drawn tiles
		var map_rect = tilemap.get_used_rect()
		var tile_size = tilemap.tile_set.tile_size
		
		# Multiply by tile size to convert grid coordinates to pixel coordinates
		var left = map_rect.position.x * tile_size.x
		var top = map_rect.position.y * tile_size.y
		var right = map_rect.end.x * tile_size.x
		var bottom = map_rect.end.y * tile_size.y
		
		# Send those boundaries to the Player
		player.set_camera_limits(left, top, right, bottom)


# This function runs ONLY when the signal is emitted
func _on_player_died():
	# Show the UI you built for Aldria Sagas
	game_over_ui.show_game_over()
	
	# Optional: Stop the game world logic
	get_tree().paused = true

func _on_boss_defeated():
	# Wait a small moment for the death animation to play out (optional)
	await get_tree().create_timer(2.0).timeout
	if win_screen:
		win_screen.show_win()
	get_tree().paused = true
