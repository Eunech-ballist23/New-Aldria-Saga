extends Area2D

@export var damage: int = 2

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		# global_position is sent so your player can calculate knockback [cite: 23]
		area.take_damage(damage, global_position)
