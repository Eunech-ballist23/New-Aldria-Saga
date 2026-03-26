extends Area2D

func _on_area_entered(area: Area2D):
	# The Player's sword must be in group "player_attack"
	if area.is_in_group("player_attack"):
		var dmg = area.get("damage") if "damage" in area else 20
		if get_parent().has_method("take_damage"):
			get_parent().take_damage(dmg)
