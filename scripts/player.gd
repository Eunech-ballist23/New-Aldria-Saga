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
@export var basic_attack_damage = 1 # Added this so you can tweak damage in the Inspector!

# --- COMBO SYSTEM VARIABLES ---
var combo_count = 0 
var combo_timer = 0.0 
@export var combo_window = 0.6 

# --- FOOTSTEP VARIABLES ---
var footstep_timer: float = 0.0 
@export var footstep_delay: float = 0.35 # Tweak this in the Inspector to match your run speed!

# --- DASH VARIABLES ---
@export var dash_speed: float = 350.0 # Speed during the dash
@export var dash_duration: float = 0.25 # How long the dash lasts
@export var dash_cooldown: float = 0.8 # Time between dashes
var is_dashing: bool = false
var dash_cooldown_timer: float = 0.0

# Preload the projectile scene 
const PROJECTILE_SCENE = preload("res://scenes/ability_projectile.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var hitbox_shape = $player_hitbox/CollisionShape2D 

var is_dead = false
var is_hurting = false
var is_attacking = false
var last_direction = "down"
var last_direction_vec = Vector2.DOWN 
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	health_changed.emit(health)
	
	# NEW: Connect the hitbox Area2D to detect overlapping bodies
	if has_node("player_hitbox"):
		$player_hitbox.body_entered.connect(_on_player_hitbox_body_entered)

func _input(event):
	if is_dead or is_hurting or is_dashing: return
	
	if event.is_action_pressed("skill_1"):
		use_skill(0, 5.0, "fireball")
	elif event.is_action_pressed("skill_2"):
		use_skill(1, 3.0, "water")
	elif event.is_action_pressed("skill_3"):
		use_skill(2, 10.0, "wind")

func use_skill(index, cooldown, anim_name):
	if skill_cooldowns[index]: 
		return 
	
	var damage_to_deal = 0
	var skill_effect = "none"
	
	if anim_name == "fireball":
		damage_to_deal = 4
		skill_effect = "none"
		AudioController.fireballSkill()
	elif anim_name == "water":
		damage_to_deal = 2
		skill_effect = "slow"
		AudioController.waterSkill()
	elif anim_name == "wind":
		damage_to_deal = 2
		skill_effect = "push"
		AudioController.windSkill()
	
	skill_cooldowns[index] = true
	
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.global_position = global_position
	projectile.direction = last_direction_vec
	
	if "damage" in projectile:
		projectile.damage = damage_to_deal
	if "effect" in projectile:
		projectile.effect = skill_effect
	
	get_tree().current_scene.add_child(projectile)
	
	if projectile.has_method("play"):
		projectile.play(anim_name)
	
	skill_used.emit(index, cooldown)
	
	await get_tree().create_timer(cooldown).timeout
	skill_cooldowns[index] = false

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

	# Handle Dash Input (Left Shift)
	dash_cooldown_timer -= delta
	if Input.is_key_pressed(KEY_SHIFT) and !is_dashing and dash_cooldown_timer <= 0:
		start_dash()
		return

	if is_dashing:
		# Velocity is handled in start_dash and remains constant during duration
		move_and_slide()
		return

	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		last_direction_vec = direction 
		last_direction = get_direction_name(direction)
		velocity = direction * speed
		sprite.play("run_" + last_direction)
		
		# --- PLAY YOUR RUN SOUND HERE ---
		footstep_timer -= delta
		if footstep_timer <= 0:
			AudioController.stepRun() 
			footstep_timer = footstep_delay # Reset the timer
			
	else:
		velocity = Vector2.ZERO
		sprite.play("idle_" + last_direction)
		
		# Reset the timer so the first step plays instantly when you move again
		footstep_timer = 0.0 

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		start_attack()

	move_and_slide()

func start_dash():
	is_dashing = true
	dash_cooldown_timer = dash_cooldown
	
	# Set dash velocity in the direction we are currently moving or facing
	velocity = last_direction_vec.normalized() * dash_speed
	
	# Play dash animation
	sprite.play("dash_" + last_direction)
	
	# Optional: Add dash sound here
	# AudioController.play_dash()

	# Duration handled by timer
	await get_tree().create_timer(dash_duration).timeout
	# is_dashing is reset here or in animation_finished
	if is_dashing:
		is_dashing = false
	
func set_camera_limits(left: int, top: int, right: int, bottom: int):
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
	
	# 1. COMBO CALCULATION
	var current_time = Time.get_unix_time_from_system()
	if current_time - combo_timer > combo_window:
		combo_count = 1
	else:
		combo_count = (combo_count % 2) + 1 
		
	combo_timer = current_time
	is_attacking = true
	
	# 2. ANIMATION NAME SELECTION
	var anim_name = "attack_" + last_direction
	if combo_count == 2:
		anim_name += "_2"

	# 3. DIRECTIONAL HITBOX POSITIONING
	match last_direction:
		"up":
			$player_hitbox.position = Vector2(0, -42) 
		"down":
			$player_hitbox.position = Vector2(0, 14)  
		"left":
			$player_hitbox.position = Vector2(-26, -12) 
		"right":
			$player_hitbox.position = Vector2(26, -12)  

	sprite.play(anim_name)
	
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", false)
	
	AudioController.slash1()

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
	elif anim.begins_with("dash"):
		is_dashing = false
	elif anim.begins_with("die"):
		set_physics_process(false)
		die()
		
func die():
	print("Player has died!")
	AudioController.playerDeadSF()
	player_died.emit()

func _on_player_hitbox_body_entered(body):
	# Check if the thing we hit can take damage (works for enemies AND bosses)
	if body.has_method("take_damage"):
		body.take_damage(basic_attack_damage, global_position)
