extends Area2D

@export var damage: int = 2

func _on_body_entered(body: Node2D):
	# The Player Root must be in group "player"
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
