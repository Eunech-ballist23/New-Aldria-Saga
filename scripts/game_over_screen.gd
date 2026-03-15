extends CanvasLayer

# Use the ColorRect as the main reference for the fade
@onready var color_rect = $ColorRect
@onready var container = $ColorRect/CenterContainer/VBoxContainer

func _ready():
	self.hide()
	# Set the background to be transparent at the start
	color_rect.color.a = 0
	container.modulate.a = 0

func show_game_over():
	print("UI is trying to show!")
	# 1. Make the CanvasLayer visible
	self.show()
	$ColorRect.show()
	
	# 2. Reset values to ensure the animation starts from "hidden"
	container.modulate.a = 0
	color_rect.color.a = 0
	
	# 3. Create the animation
	var tween = create_tween().set_parallel(true)
	
	# Fade in the background dim (to 80% black)
	tween.tween_property(color_rect, "color:a", 0.8, 0.5)
	
	# Fade in the buttons and text
	tween.tween_property(container, "modulate:a", 1.0, 0.5)
	
	# Instead of fighting the Container's 'position', 
	# let's use 'scale' for a cool pop-in effect!
	container.pivot_offset = container.size / 2 # Set pivot to center
	container.scale = Vector2(0.8, 0.8)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
