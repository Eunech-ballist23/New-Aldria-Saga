# Attach this to your World/Level root node
extends Node2D

@onready var player = $Player
@onready var health_bar = $HUD/HealthBar

func _ready() -> void:
	# Establish the link
	player.health_changed.connect(health_bar.update_health)
