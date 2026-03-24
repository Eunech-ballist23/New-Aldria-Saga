extends CharacterBody2D
class_name Player

signal skill_used(slot_index, cooldown_time)
var skill_cooldowns = [false, false, false]
# Signal to notify the HUD when health changes
signal health_changed(new_health)
# Signal when a player died
signal player_died

@export var health = 10
@export var speed = 90
@export var knockback_strength = 250.0

# Preload the projectile scene 
const PROJECTILE_SCENE = preload("res://scenes/ability_projectile.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var hitbox_shape = $player_hitbox/CollisionShape2D 

var is_dead = false
var is_hurting = false
var is_attacking = false
var last_direction = "down"
var last_direction_vec = Vector2.DOWN # Added to track vector for shooting
var knockback_velocity: Vector2 = Vector2.ZERO

func _input(event):
	if is_dead or is_hurting: return
	
	# Pass the skill index, cooldown, and the animation name to use_skill 
	if event.is_action_pressed("skill_1"):
		use_skill(0, 5.0, "fireball")
	elif event.is_action_pressed("skill_2"):
		use_skill(1, 3.0, "water")
	elif event.is_action_pressed("skill_3"):
		use_skill(2, 10.0, "wind")

# Updated function signature to accept three arguments 
func use_skill(index, cooldown, anim_name):
	# 1. Check if the specific slot is already on cooldown [cite: 51]
	if skill_cooldowns[index]: 
		return 
	
	# 2. Start the internal cooldown [cite: 51]
	skill_cooldowns[index] = true
	
	# 3. Projectile Spawning Logic [cite: 51]
	var projectile = PROJECTILE_SCENE.instantiate()
	
	# Set the projectile to spawn at the player's current position [cite: 51]
	projectile.global_position = global_position
	
	# Use the saved direction vector so it fires where the player is facing [cite: 51]
	projectile.direction = last_direction_vec
	
	# Add the projectile to the current game scene [cite: 51]
	get_tree().current_scene.add_child(projectile)
	
	# Play the specific animation (fireball, water, or wind) [cite: 51, 53]
	projectile.play(anim_name)
	
	# 4. Tell the HUD to start the visual cooldown [cite: 51]
	skill_used.emit(index, cooldown)
	
	# 5. Wait for the duration, then allow the skill again [cite: 51]
	await get_tree().create_timer(cooldown).timeout
	skill_cooldowns[index] = false

func _ready() -> void:
	# Sync the HealthBar with starting health immediately [cite: 51]
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
		last_direction_vec = direction # Save the raw vector for shooting direction
		last_direction = get_direction_name(direction)
		velocity = direction * speed
		sprite.play("run_" + last_direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle_" + last_direction)

	# Using the corrected Left Mouse Button for attack [cite: 52]
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		start_attack()

	move_and_slide()
	
func set_camera_limits(left: int, top: int, right: int, bottom: int):
	# This requires a Camera2D node to be attached to the Player [cite: 52]
	if has_node("Camera2D"):
		$Camera2D.limit_left = left
		$Camera2D.limit_top = top
		$Camera2D.limit_right = right
		$Camera2D.limit_bottom = bottom

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
		die()
		
func die():
	print("Player has died!")
	player_died.emit()
