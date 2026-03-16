extends Area2D

# This function is called by the player's hitbox
func take_damage(amount: int, attacker_pos: Vector2):
	# owner refers to the root node of the scene (GolemBoss)
	if owner.has_method("take_damage"):
		owner.take_damage(amount, attacker_pos)
