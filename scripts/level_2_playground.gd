extends Node2D

@onready var player = $Player
@onready var health_bar = $HUD/HealthBar
@onready var game_over_ui = $GameOverScreen
@onready var win_screen = $WinScreen

func _ready() -> void:
	# 1. Connect the Player Death Signal
	if has_node("Player"):
		$Player.player_died.connect(_on_player_died)
	else:
		print("Error: Player node not found!")
	
	# 2. Connect the Health Signal
	if player and health_bar:
		player.health_changed.connect(health_bar.update_health)
	
	# 3. Connect the Boss (Wraith) defeat signal
	if has_node("Wraith"):
		$Wraith.boss_defeated.connect(_on_boss_defeated)
	else:
		print("Warning: Wraith boss node not found!")

# Runs when the player dies
func _on_player_died():
	game_over_ui.show_game_over()
	get_tree().paused = true

# Runs when the Wraith boss is defeated
func _on_boss_defeated():
	print("Boss defeated! Showing win screen.")
	get_tree().paused = false
	if win_screen:
		win_screen.show_win()
