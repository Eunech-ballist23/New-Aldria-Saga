extends CanvasLayer

# --- Creates a slot in the Inspector to choose the next level ---
@export_file("*.tscn") var next_level_path: String

# Target the ColorRect which contains all your UI elements
@onready var background = $ColorRect 
@export var next_level: Button

func _ready() -> void:
	# Start with the background transparent
	if background:
		background.modulate.a = 0.0
	hide() 

func show_win():
	show()
	
	# --- Hide the "Next Level" button if this is the final level! ---
	if next_level:
		if next_level_path == "":
			next_level.hide()
		else:
			next_level.show()
	
	if background:
		# Create the Tween to handle the smooth transition on the ColorRect
		var tween = create_tween()
		
		# Transition the background's alpha from 0.0 to 1.0 over 1.5 seconds
		tween.tween_property(background, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
	
	# This allows the UI to work even if the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_next_level_pressed():
	print("THE BUTTON WAS CLICKED!") # <--- Add this line!
	
	get_tree().paused = false
	
	if next_level_path != "":
		print("Trying to load: ", next_level_path) # <--- Add this line!
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("Warning: You forgot to set the next_level_path in the Inspector!")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	# Adjust this path if your main menu is called something else
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_game_pressed() -> void:
	get_tree().quit()
