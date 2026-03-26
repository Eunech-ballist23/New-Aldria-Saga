extends Area2D

@export var damage: int = 25

func _ready():
	add_to_group("enemy_hitbox")
	# Hitboxes should usually be disabled until an animation frame enables them
	monitoring = false 

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			# Sending (Damage, Position) to match Player's requirements
			body.take_damage(damage, global_position)
