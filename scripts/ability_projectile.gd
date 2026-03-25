extends Area2D

@export var speed = 250
var direction = Vector2.ZERO
var damage = 0 
var effect = "none" # <--- IMPORTANT: Added to carry the skill effect

@onready var sprite = $AnimatedSprite2D

func _ready():
	if direction != Vector2.ZERO:
		rotation = direction.angle()

func _physics_process(delta):
	global_position += direction * speed * delta

func play(anim_name: String):
	if sprite == null: sprite = $AnimatedSprite2D
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

# Detects the Slime/Goblin Hurtbox (Area2D)
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		# Pass the effect to the hurtbox
		area.take_damage(damage, global_position, effect)
		queue_free() 

# Detects solid walls or the Enemy Body
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		# Pass the effect to the body
		body.take_damage(damage, global_position, effect)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
