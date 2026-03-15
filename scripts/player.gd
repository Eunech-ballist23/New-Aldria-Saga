extends CharacterBody2D
class_name Player

# Signal to notify the HUD when health changes
signal health_changed(new_health)
#signal when a player died
signal player_died

@export var health = 20
@export var speed = 90
@export var knockback_strength = 250.0

@onready var sprite = $AnimatedSprite2D
@onready var hitbox_shape = $player_hitbox/CollisionShape2D 

var is_dead = false
var is_hurting = false
var is_attacking = false
var last_direction = "down"
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Sync the HealthBar with starting health immediately
	health_changed.emit(health)

func _physics_process(delta):
	if is_dead: return 
	
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000 * delta)
		move_and_slide()
		return

	if is_attacking or is_hurting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		last_direction = get_direction_name(direction)
		velocity = direction * speed
		sprite.play("run_" + last_direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle_" + last_direction)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		start_attack()

	move_and_slide()

func get_direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"

func start_attack():
	if is_attacking or is_hurting: return
	is_attacking = true
	sprite.play("attack_" + last_direction)
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", false)

func take_damage(amount: int, attacker_pos: Vector2):
	if is_dead: return
	
	health -= amount
	# Update the UI via signal
	health_changed.emit(health)
	
	is_hurting = true
	is_attacking = false 
	
	if hitbox_shape: 
		hitbox_shape.set_deferred("disabled", true)
	
	var bounce_dir = attacker_pos.direction_to(global_position)
	knockback_velocity = bounce_dir * knockback_strength
	
	var dir = get_direction_name(bounce_dir)

	if health <= 0:
		is_dead = true
		sprite.play("die_" + dir)
	else:
		sprite.play("hurt_" + dir)

func _on_animated_sprite_2d_animation_finished():
	var anim = sprite.animation
	if anim.begins_with("attack"):
		is_attacking = false
		if hitbox_shape: 
			hitbox_shape.set_deferred("disabled", true)
	elif anim.begins_with("hurt"):
		is_hurting = false
	elif anim.begins_with("die"):
		set_physics_process(false)
		
func die():
	print("Player has died!")
	player_died.emit()
