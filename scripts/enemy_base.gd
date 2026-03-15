extends CharacterBody2D
class_name EnemyBase

@export var health: int = 3
@export var max_health: int = health
@export var speed: int = 50
@export var knockback_strength: float = 150.0 
@export var attack_range: float = 40.0
@export var hitbox_shape: CollisionShape2D 

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $EnemyHealthBar

# Add this variable at the top with your other states 
var is_invincible: bool = false
var is_attacking: bool = false
var is_hurting: bool = false 
var is_dead: bool = false    
var player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var is_wandering: bool = false
var wander_direction: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

func _ready():
	pick_new_state()
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	# --- SPAWN INVINCIBILITY ---
	is_invincible = true
	# Enemy is invincible for 1.5 seconds after spawning
	get_tree().create_timer(1.5).timeout.connect(func(): is_invincible = false)
	
	#Initialize health bar
	if health_bar:
		health_bar.update_health(health, max_health)

func _physics_process(delta: float):
	if is_dead: return
	
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
		move_and_slide()
		return
		
	# While hurting or attacking, the enemy stays still
	if is_hurting or is_attacking:
		velocity = Vector2.ZERO
	elif player:
		process_combat_logic()
	else:
		process_wander_logic(delta)
	move_and_slide()

func process_combat_logic():
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		start_attack()
	else:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		update_animation(dir)

func start_attack():
	# If already hurting, don't start a new attack
	if is_attacking or is_hurting or is_dead: return
	
	is_attacking = true
	var dir_name = get_direction_name(global_position.direction_to(player.global_position))
	sprite.play("attack_" + dir_name)
	
	# Delay damage to match the visual swing frame
	await get_tree().create_timer(0.2).timeout 
	
	# RE-CHECK: If the enemy was hit (is_hurting) during the timer, don't enable the hitbox
	if is_attacking and not is_hurting and not is_dead and hitbox_shape:
		hitbox_shape.set_deferred("disabled", false)

func take_damage(amount: int, attacker_pos: Vector2):
	# Exit if already dead or currently invincible 
	if is_dead or is_invincible: return
	
	#Invincible logic 
	is_invincible = true
	#start a timer to turn off invincibility after 1 second
	get_tree().create_timer(1.0).timeout.connect(func(): is_invincible = false)
	
	# --- ATTACK CANCEL LOGIC ---
	is_hurting = true
	is_attacking = false # Force attack state to false
	
	# Immediately stop the attack animation and disable the hitbox
	sprite.stop() 
	if hitbox_shape: 
		hitbox_shape.set_deferred("disabled", true)
	# ---------------------------

	health -= amount
	#Update the healthbar visual (which now handles its own visibility)
	if health_bar:
		health_bar.update_health(health, max_health)
	
	flash_red()
	apply_knockback(attacker_pos)
	
	var dir_name = get_direction_name(attacker_pos.direction_to(global_position))
	
	if health <= 0:
		is_dead = true
		sprite.play("death_" + dir_name)
	else:
		sprite.play("hurt_" + dir_name)

func flash_red():
	sprite.modulate = Color(10, 1, 1)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

func apply_knockback(from_pos: Vector2):
	knockback_velocity = from_pos.direction_to(global_position) * knockback_strength

func update_animation(dir: Vector2):
	if dir == Vector2.ZERO: return
	sprite.play("run_" + get_direction_name(dir))

func get_direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"

func process_wander_logic(delta):
	state_timer -= delta
	if state_timer <= 0: pick_new_state()
	if is_wandering:
		velocity = wander_direction * (speed * 0.6)
		update_animation(wander_direction)
	else:
		velocity = Vector2.ZERO

func pick_new_state():
	is_wandering = randf() > 0.5
	state_timer = randf_range(1.0, 3.0)
	wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()

func _on_animated_sprite_2d_animation_finished():
	var anim = sprite.animation
	if anim.begins_with("attack"):
		is_attacking = false
		if hitbox_shape: 
			hitbox_shape.set_deferred("disabled", true)
	elif anim.begins_with("hurt"):
		is_hurting = false # Enemy is now ready to attack again
	elif anim.begins_with("death"):
		queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"): player = body

func _on_detection_area_body_exited(body):
	if body == player: player = null
