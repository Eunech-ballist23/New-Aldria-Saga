extends Control

@onready var background = $Background

# Load your textures here
var village_bg = preload("res://assets/GameUIDesign/medieval_village.jpg")
var desert_bg = preload("res://assets/GameUIDesign/desser_image.jpg")

func _ready():
	# Connect Level 1 (Desert)
	$Level1.pressed.connect(func(): _load_level("res://scenes/Game_Level/playground.tscn"))
	$Level1.mouse_entered.connect(func(): background.texture = village_bg)

	# Connect Level 2 (Forest)
	$Level2.pressed.connect(func(): _load_level("res://scenes/Game_Level/level_2_playground.tscn"))
	$Level2.mouse_entered.connect(func(): background.texture = desert_bg)

	# Connect Level 3 (Snow/Tundra)
	
# Simple helper function to change scenes
func _load_level(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
