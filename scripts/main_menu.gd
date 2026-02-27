extends Control

@onready var start_button = $VBoxContainer/PlayButton as Button
@onready var option_button = $VBoxContainer/SettingsButton as Button
@onready var quit_button = $VBoxContainer/QuitButton as Button

@export var start_level = preload("res://scenes/Game_Level/playground.tscn") as PackedScene

func _ready():
	start_button.button_down.connect(on_start_pressed)
	quit_button.button_down.connect(on_exit_pressed)

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
	get_tree().quit() # This closes the game application
