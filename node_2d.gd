extends Node2D

@onready var enemy  = preload("res://scenes/Enemy/slime.tscn")



func _on_timer_timeout() -> void:
	var ene = enemy.instantiate()
	ene.position = position
	get_parent().get_node("enemy").add_child(ene)
