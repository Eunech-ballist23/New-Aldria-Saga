extends Area2D

@export var speed = 250
var direction = Vector2.ZERO # Received from player.gd

@onready var sprite = $AnimatedSprite2D

func _ready():
	# 1. Rotate the projectile to face the movement direction
	if direction != Vector2.ZERO:
		# This aligns the +X axis (right) of your sprite to the direction vector
		rotation = direction.angle() 
	
	# 2. Safety check for the Sprite
	if not sprite:
		sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Move straight in the direction assigned
	global_position += direction * speed * delta

func play(anim_name: String):
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		print("Animation " + anim_name + " not found!")

func _on_body_entered(body):
	# Basic damage logic
	if body.has_method("take_damage"):
		body.take_damage(2, global_position) 
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
