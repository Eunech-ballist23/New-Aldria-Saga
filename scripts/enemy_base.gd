extends CharacterBody2D
class_name EnemyBase

@export var health: int = 3
@export var max_health: int = 3
@export var speed: int = 50
@export var knockback_strength: float = 150.0 
@export var attack_range: float = 40.0
@export var hitbox_shape: CollisionShape2D 

# --- LOOT SYSTEM ---
# Drag your coins.tscn into this slot in the Inspector
@export var loot_item: PackedScene = preload("res://scenes/coins.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $EnemyHealthBar

var is_invincible: bool = false
var is_attacking: bool = false
var is_hurting: bool = false 
var is_dead: bool = false    
var player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
var is_wandering: bool = false
var wander_direction: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

# EFFECT VARIABLES
var original_speed: int 
var is_slowed: bool = false

func _ready():
	original_speed = speed 
	max_health = health
	pick_new_state()
	
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
		
	is_invincible = true
	get_tree().create_timer(1.5).timeout.connect(func(): is_invincible = false)
	
	if health_bar:
		health_bar.update_health(health, max_health)

func _physics_process(delta: float):
	if is_dead: return
	
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
		move_and_slide()
		return
		
	if is_hurting or is_attacking:
		velocity = Vector2.ZERO
	elif player:
		process_combat_logic()
	else:
		process_wander_logic(delta)
	move_and_slide()

func take_damage(amount: int, attacker_pos: Vector2, effect: String = "none"):
	if is_dead or is_invincible: return
	
	AudioController.mobTakeDamage()
	
	if effect == "slow":
		apply_slow_effect(2.5)
	
	var push_multiplier = 1.0
	if effect == "push":
		push_multiplier = 3.5 
	
	health -= amount
	if health_bar:
		health_bar.update_health(health, max_health)
	
	is_invincible = true
	get_tree().create_timer(0.5).timeout.connect(func(): is_invincible = false)
	
	is_hurting = true
	is_attacking = false 
	sprite.stop() 
	
	if hitbox_shape: 
		hitbox_shape.set_deferred("disabled", true)

	flash_red()
	apply_knockback(attacker_pos, push_multiplier)
	
	var dir_name = get_direction_name(attacker_pos.direction_to(global_position))
	if health <= 0:
		is_dead = true
		sprite.play("death_" + dir_name)
		AudioController.mobDeadSF()
	else:
		sprite.play("hurt_" + dir_name)

func apply_slow_effect(duration: float):
	if is_slowed: return 
	is_slowed = true
	speed = int(original_speed * 0.4) 
	sprite.modulate = Color(0.5, 0.5, 1.0) 
	
	await get_tree().create_timer(duration).timeout
	
	speed = original_speed
	if not is_dead: sprite.modulate = Color(1, 1, 1)
	is_slowed = false

func apply_knockback(from_pos: Vector2, multiplier: float = 1.0):
	var strength = knockback_strength * multiplier
	knockback_velocity = from_pos.direction_to(global_position) * strength

func flash_red():
	if is_slowed: return
	sprite.modulate = Color(10, 1, 1)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

# --- LOOT SPAWNING ---
func spawn_loot():
	if loot_item:
		var loot_instance = loot_item.instantiate()
		loot_instance.global_position = global_position
		# Always add loot to the root of the scene, not the enemy
		get_tree().current_scene.add_child(loot_instance)

# --- COMBAT & WANDER LOGIC ---

func process_combat_logic():
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		start_attack()
	else:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		update_animation(dir)

func start_attack():
	if is_attacking or is_hurting or is_dead: return
	is_attacking = true
	var dir_name = get_direction_name(global_position.direction_to(player.global_position))
	sprite.play("attack_" + dir_name)
	await get_tree().create_timer(0.2).timeout 
	if is_attacking and not is_hurting and not is_dead and hitbox_shape:
		hitbox_shape.set_deferred("disabled", false)

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

func update_animation(dir: Vector2):
	if dir == Vector2.ZERO: return
	sprite.play("run_" + get_direction_name(dir))

func get_direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"

func _on_animated_sprite_2d_animation_finished():
	var anim = sprite.animation
	if anim.begins_with("attack"):
		is_attacking = false
		if hitbox_shape: 
			hitbox_shape.set_deferred("disabled", true)
	elif anim.begins_with("hurt"):
		is_hurting = false 
	elif anim.begins_with("death"):
		spawn_loot() # Drops the coins right before the enemy is removed
		queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"): player = body

func _on_detection_area_body_exited(body):
	if body == player: player = null
