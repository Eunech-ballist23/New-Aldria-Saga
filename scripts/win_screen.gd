extends CanvasLayer

# Target the ColorRect which contains all your UI elements
@onready var background = $ColorRect 

func _ready() -> void:
	# Start with the background transparent
	if background:
		background.modulate.a = 0.0
	hide() 

func show_win():
	show()
	
	if background:
		# Create the Tween to handle the smooth transition on the ColorRect
		var tween = create_tween()
		
		# Transition the background's alpha from 0.0 to 1.0 over 1.5 seconds
		tween.tween_property(background, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	# This allows the UI to work even if the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_level_pressed():
	get_tree().paused = false
	# Add your next scene path here when ready
	# get_tree().change_scene_to_file("res://scenes/level_2.tscn")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
