# hud_manager.gd
extends CanvasLayer

@onready var slots = [
	$MainUI/Bottom_center/skill_bar/Skill1,
	$MainUI/Bottom_center/skill_bar/Skill2,
	$MainUI/Bottom_center/skill_bar/Skill3
]

func _ready():
	# Replace 'Player' with the actual path to your player node
	var player = get_tree().get_first_node_in_group("player") 
	if player:
		player.skill_used.connect(_on_player_skill_used)

func _on_player_skill_used(index, cooldown):
	if index < slots.size():
		slots[index].start_cooldown(cooldown)
