extends Area2D
@export var damage_amount: int = 1
func _on_area_entered(area: Area2D):
	print("DEBUG: Player sword hit: ", area.name)
	if area.has_method("take_damage"):
		area.take_damage(damage_amount, global_position)
