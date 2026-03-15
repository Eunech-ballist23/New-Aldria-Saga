extends Node2D

@onready var player = $Player
@onready var health_bar = $HUD/HealthBar
@onready var game_over_ui = $GameOverScreen

func _ready() -> void:
	# 1. Connect the Death Signal
	if has_node("Player"):
		# REMOVED the () from the end of the function name
		$Player.player_died.connect(_on_player_died)
	else:
		print("Error: Player node not found!")
	
	# 2. Connect the Health Signal
	if player and health_bar:
		player.health_changed.connect(health_bar.update_health)

# This function runs ONLY when the signal is emitted
func _on_player_died():
	# Show the UI you built for Aldria Sagas
	game_over_ui.show_game_over()
	
	# Optional: Stop the game world logic
	get_tree().paused = true
