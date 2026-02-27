extends Area2D
func take_damage(amount: int, attacker_pos: Vector2):
	print("DEBUG: Enemy Hurtbox hit!")
	var parent = get_parent()
	if parent.has_method("take_damage"):
		parent.take_damage(amount, attacker_pos)
