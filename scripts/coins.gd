extends Area2D

@export var coin_value: int = 1
@export var fade_duration: float = 0.4
var is_collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	# Ensure only the player triggers this
	if body.is_in_group("player") and not is_collected:
		collect_coin()

func collect_coin():
	is_collected = true
	
	# 1. TELL THE AUDIO MANAGER TO PLAY
	# Replace 'AudioManager' with whatever name you gave it in Project Settings -> Autoload
	if AudioManager:
		AudioManager.play_coin_sound()
	
	# 2. THE FADE AND FLOAT EFFECT
	var tween = create_tween()
	
	# Fade transparency to zero
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	# Move upward slightly (float away)
	tween.parallel().tween_property(self, "position:y", position.y - 40, fade_duration)
	
	# Shrink while fading
	tween.parallel().tween_property(self, "scale", Vector2(0.3, 0.3), fade_duration)
	
	# 3. DELETE THE COIN NODE
	tween.finished.connect(queue_free)
