extends Area2D
func _on_area_entered(area: Area2D):
	print("DEBUG: Enemy weapon hit: ", area.name)
	if area.has_method("take_damage"):
		area.take_damage(1, global_position)
