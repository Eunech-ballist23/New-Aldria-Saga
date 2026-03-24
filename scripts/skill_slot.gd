extends PanelContainer

@onready var progress_bar = $TextureProgressBar
@onready var timer = $Timer

func _ready():
	# Ensure the cooldown overlay is hidden initially
	progress_bar.value = 0
	progress_bar.max_value = 100

func _process(_delta):
	if not timer.is_stopped():
		# Calculate the remaining time as a percentage for the progress bar
		# (Time Left / Total Wait Time) * 100
		progress_bar.value = (timer.time_left / timer.wait_time) * 100
	else:
		progress_bar.value = 0

func start_cooldown(duration: float):
	# Called by hud.gd when the player emits the skill_used signal [cite: 48]
	timer.wait_time = duration
	timer.start()
