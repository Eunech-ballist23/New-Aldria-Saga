# scripts/enemy_health_bar.gd
extends ProgressBar

@onready var catch_up_bar = $DamageBar 

func _ready():
	# Keep health bar hidden until damage is taken
	hide() 

func update_health(current_health: int, max_health: int):
	# Show the bar only when updating health
	show() 
	
	value = (float(current_health) / max_health) * 100
	
	var tween = get_tree().create_tween()
	tween.tween_property(catch_up_bar, "value", value, 0.4).set_trans(Tween.TRANS_SINE)
