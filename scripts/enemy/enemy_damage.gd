extends Area2D

# This allows you to set unique damage for each mob in the Inspector
@export var damage_amount: int = 1 

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		# Pass the specific damage_amount to the player
		area.take_damage(damage_amount, global_position)
