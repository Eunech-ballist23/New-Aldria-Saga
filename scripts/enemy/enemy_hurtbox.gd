extends Area2D

func take_damage(amount: int, attacker_pos: Vector2, effect: String = "none"):
	var parent = get_parent()
	if parent and parent.has_method("take_damage"):
		# We must pass 'effect' here!
		parent.take_damage(amount, attacker_pos, effect)
