extends Area2D

# --- NEW: Added 'effect' as the 3rd argument with a default of "none" ---
func take_damage(amount: int, attacker_pos: Vector2, effect: String = "none"):
	
	# Pass all 3 pieces of information up to the main Boss script
	if owner.has_method("take_damage"):
		owner.take_damage(amount, attacker_pos, effect)
