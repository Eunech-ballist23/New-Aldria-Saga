extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var container = $ColorRect/CenterContainer/VBoxContainer

func _ready():
	self.hide()
	# This is the most important line! 
	# It allows the buttons to work even when the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS 
	color_rect.color.a = 0
	container.modulate.a = 0

func show_game_over():
	self.show()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(color_rect, "color:a", 0.8, 0.5)
	tween.tween_property(container, "modulate:a", 1.0, 0.5)
	
	container.pivot_offset = container.size / 2 
	container.scale = Vector2(0.8, 0.8)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# --- THESE ARE THE BUTTON FUNCTIONS ---


func _on_retry_pressed() -> void:
	print("Restarting...")
	get_tree().paused = false # Unpause so the game can run again
	get_tree().reload_current_scene() # Reloads playground.gd 


func _on_exit_game_pressed() -> void:
	print("Quitting...")
	get_tree().quit()
