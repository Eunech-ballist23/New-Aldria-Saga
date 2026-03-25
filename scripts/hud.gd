# hud_manager.gd
extends CanvasLayer

@onready var slots = [
	$MainUI/Bottom_center/skill_bar/Skill1,
	$MainUI/Bottom_center/skill_bar/Skill2,
	$MainUI/Bottom_center/skill_bar/Skill3
]

func _ready():
	var player = get_tree().get_first_node_in_group("player") 
	
	# Verify the node exists AND it's actually the player (has the signal)
	if player:
		if player.has_signal("skill_used"):
			player.skill_used.connect(_on_player_skill_used)
		else:
			print("HUD Error: Found 'player' group member, but it's not the Player Character!")
	else:
		print("HUD Error: No node found in 'player' group.")

func _on_player_skill_used(index, cooldown):
	if index < slots.size():
		slots[index].start_cooldown(cooldown)
