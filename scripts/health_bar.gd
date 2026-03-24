extends ProgressBar

@onready var damage_bar = $DamageBar #
@onready var timer = $Timer #

func _ready() -> void:
	max_value = 10 #
	damage_bar.max_value = 20 #
	# Only use this if you disconnected it from the Editor
	timer.timeout.connect(_on_timer_timeout) #

func update_health(new_health: int) -> void:
	var prev_health = value
	value = new_health #
	
	if new_health < prev_health:
		timer.start() #
	else:
		damage_bar.value = new_health #

func _on_timer_timeout() -> void:
	damage_bar.value = value #
