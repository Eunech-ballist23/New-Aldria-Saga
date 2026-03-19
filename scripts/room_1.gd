extends Node2D

@onready var player = $Player
@onready var health_bar = $HUD/HealthBar
@onready var game_over_ui = $GameOverScreen
@onready var win_screen = $WinScreen
@onready var victory_sound = $VictorySound 

func _ready() -> void:
	# 1. Get the TileMap (Ensure this name matches your Scene Dock exactly!)
	var tilemap = $TileMapLayer 
	
	if tilemap:
		var map_rect = tilemap.get_used_rect()
		var cell_size = tilemap.tile_set.tile_size
		
		# Correct math: position is the top-left, end is the bottom-right
		var left = map_rect.position.x * cell_size.x
		var top = map_rect.position.y * cell_size.y
		var right = map_rect.end.x * cell_size.x
		var bottom = map_rect.end.y * cell_size.y
		
		if player:
			player.set_camera_limits(left, top, right, bottom)
	else:
		print("Error: TileMapLayer node not found! Check the name in the Scene Dock.")
	
	
	# 1. Connect the Death Signal
	if has_node("Player"):
		# REMOVED the () from the end of the function name
		$Player.player_died.connect(_on_player_died)
	else:
		print("Error: Player node not found!")
	
	# 2. Connect the Health Signal
	if player and health_bar:
		player.health_changed.connect(health_bar.update_health)
		
	# 3. NEW: Connect the Golem Death Signal
	if has_node("GolemBoss"):
		$GolemBoss.boss_died.connect(_on_boss_killed)

# This function runs ONLY when the signal is emitted
func _on_player_died():
	# Show the UI you built for Aldria Sagas
	game_over_ui.show_game_over()
	
	# Optional: Stop the game world logic
	get_tree().paused = true
	
# NEW: Function to handle the win
func _on_boss_killed():
	# 1. Play the victory sound immediately [cite: 109]
	if victory_sound:
		victory_sound.play()
	
	# Wait for 3 seconds [cite: 105]
	await get_tree().create_timer(3.0).timeout
	
	if win_screen:
		win_screen.show_win() # Or call a custom function like win_screen.play_win_anim()
		# Optional: pause the game so enemies stop moving
		get_tree().paused = true
