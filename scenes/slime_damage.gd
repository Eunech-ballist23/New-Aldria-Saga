extends Area2D

func take_damage(amount: int, attacker_pos: Vector2):
	# This passes the damage UP to the main Enemy script (EnemyBase)
	var parent = get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage(amount, attacker_pos)
	else:
		print("Error: Hurtbox parent is missing take_damage method!")
