extends CharacterBody2D

signal boss_died # manual script signal that can be used on win screen when it returns death animation

# Stats
@export var max_health: int = 5
@export var current_health: int = 5
@export var speed: float = 40.0 
@export var acceleration: float = 200.0
@export var gravity: float = 0.0 # Top-down/4-way movement

# States
enum State { IDLE, WANDER, CHASE, ATTACK, DEATH }
var current_state: State = State.IDLE
var player: Node2D = null
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box_collision: CollisionShape2D = $GolemNormalAttack_HitBox/CollisionShape2D
@onready var detection_area: Area2D = $area_detection
@onready var health_bar = $GolemBossHealthBar

func _ready() -> void:
	current_health = max_health
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	if hit_box_collision:
		hit_box_collision.disabled = true
	_pick_new_wander_target()

func _physics_process(delta: float) -> void:
	if current_state == State.DEATH: return

	match current_state:
		State.IDLE:
			_handle_idle(delta)
		State.WANDER:
			_handle_wander(delta)
		State.CHASE:
			_handle_chase(delta)
		State.ATTACK:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)

	move_and_slide()
	_update_flip()

func _handle_idle(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	sprite.play("idle")
	
	wander_timer -= delta
	if wander_timer <= 0:
		current_state = State.WANDER
		_pick_new_wander_target()
	
	_check_for_player()

func _handle_wander(delta: float) -> void:
	# Move in a random 4-directional/diagonal vector
	velocity = velocity.move_toward(wander_direction * speed, acceleration * delta)
	sprite.play("walk")
	
	wander_timer -= delta
	if is_on_wall() or wander_timer <= 0:
		current_state = State.IDLE
		wander_timer = randf_range(1.0, 3.0)
	
	_check_for_player()

func _handle_chase(delta: float) -> void:
	if player:
		# REVISED: Stop chasing/attacking if the player is dead
		if player.is_dead:
			player = null
			current_state = State.IDLE
			return

		var dir = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		sprite.play("walk")
		
		var dist = global_position.distance_to(player.global_position)
		if dist < 45.0: 
			_start_attack()
		elif dist > 200.0: 
			player = null
			current_state = State.IDLE
	else:
		current_state = State.IDLE

func _check_for_player() -> void:
	if detection_area:
		var bodies = detection_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player") and not body.is_dead:
				player = body
				current_state = State.CHASE

func _pick_new_wander_target() -> void:
	# Pick a random direction (360 degrees)
	var angle = randf() * 2 * PI
	wander_direction = Vector2(cos(angle), sin(angle)).normalized()
	wander_timer = randf_range(2.0, 4.0)

func _update_flip() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		$GolemNormalAttack_HitBox.scale.x = 1
	elif velocity.x < 0:
		sprite.flip_h = true
		$GolemNormalAttack_HitBox.scale.x = -1

func _start_attack() -> void:
	current_state = State.ATTACK
	sprite.play("normal_attack")
	await get_tree().create_timer(0.4).timeout
	if current_state != State.DEATH and hit_box_collision:
		hit_box_collision.disabled = false
	await sprite.animation_finished
	if hit_box_collision:
		hit_box_collision.disabled = true
	current_state = State.IDLE

# --- UPDATED: Now accepts the 3rd 'effect' argument safely! ---
func take_damage(amount: int, _pos: Vector2, effect: String = "none"):
	current_health -= amount
	
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
		
	# Optional logic if you want the boss to be affected by the slow/push
	if effect == "slow":
		print("Golem Boss is slowed!")
	elif effect == "push":
		print("Golem Boss is pushed back!")
		
	if current_health <= 0:
		_die()

func _die() -> void:
	current_state = State.DEATH
	velocity = Vector2.ZERO
	# Emit the signal so room_1.gd knows the boss is dead
	boss_died.emit()
	
	sprite.play("death")
	await sprite.animation_finished
	sprite.stop()
