extends CanvasLayer

# --- Creates a slot in the Inspector to choose the next level ---
@export_file("*.tscn") var next_level_path: String

# Target the ColorRect which contains all your UI elements
@onready var background = $ColorRect 
@onready var label = $ColorRect/CenterContainer/VBoxContainer/Label
@onready var next_level_btn = $ColorRect/CenterContainer/VBoxContainer/NextLevel
@onready var exit_btn = $ColorRect/CenterContainer/VBoxContainer/ExitGame

func _ready() -> void:
	# Start with the background transparent
	if background:
		background.modulate.a = 0.0
	hide() 

func show_win():
	show()
	
	# --- Hide the "Next Level" button if this is the final level! ---
	if next_level_btn:
		if next_level_path == "" or next_level_path == null:
			next_level_btn.hide()
		else:
			next_level_btn.show()
	
	if background:
		# Create the Tween for a premium fade-in effect
		var tween = create_tween().set_parallel(true)
		
		# Fade in the background
		tween.tween_property(background, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Scale up the label for a punchy effect
		if label:
			label.scale = Vector2(0.5, 0.5)
			label.pivot_offset = label.size / 2
			tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
		# Chain a pulse effect after the fade
		tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE)
	
	# This allows the UI to work even if the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_level_pressed():
	get_tree().paused = false
	if next_level_path != "" and next_level_path != null:
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("Warning: No next level path set!")

func _on_title_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game_ui.tscn")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
