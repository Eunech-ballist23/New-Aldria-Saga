extends CharacterBody2D

signal boss_defeated

@export_group("Stats")
@export var max_health: int = 500
@export var move_speed: float = 60.0
@export var attack_range: float = 50.0

var current_health: int
var target: Node2D = null
var is_dead: bool = false
var is_acting: bool = false 

@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var health_bar = get_node_or_null("EnemyHealthBar")
@onready var attack_timer: Timer = get_node_or_null("AttackTimer")

func _ready():
	current_health = max_health
	add_to_group("enemies")
	add_to_group("boss")
	
	if health_bar and health_bar.has_method("init_health"):
		health_bar.init_health(max_health)

func _physics_process(_delta):
	if is_dead: return

	# Safety: If target is deleted/dead, clear reference
	if target != null and !is_instance_valid(target):
		target = null

	# If currently attacking or staggering, stay still
	if is_acting:
		velocity = Vector2.ZERO
		return

	if !target: 
		velocity = Vector2.ZERO
		_play_animation("idle")
		return

	var dist = global_position.distance_to(target.global_position)
	
	if dist <= attack_range:
		velocity = Vector2.ZERO
		if attack_timer and attack_timer.is_stopped():
			perform_attack()
		else:
			_play_animation("idle")
	else:
		var dir = global_position.direction_to(target.global_position)
		_handle_flip(dir.x)
		velocity = dir * move_speed
		move_and_slide()
		_play_animation("walk")

func _handle_flip(move_x: float):
	if move_x != 0:
		var is_left = move_x < 0
		if has_node("Sprite2D"): $Sprite2D.flip_h = is_left
		if anim_sprite: anim_sprite.flip_h = is_left
		if has_node("Hitbox"):
			$Hitbox.scale.x = -1 if is_left else 1

func perform_attack():
	is_acting = true
	
	if current_health < (max_health * 0.3) and _has_animation("attack_down_3"):
		_play_animation("attack_down_3")
	else:
		_play_animation("attack_down_2")
	
	if attack_timer:
		attack_timer.start()
	
	# SAFETY UNFREEZE: Forces boss to move again after 1.5s even if signals fail
	await get_tree().create_timer(1.5).timeout
	if !is_dead:
		is_acting = false

func take_damage(amount: int, _attacker_pos: Vector2 = Vector2.ZERO):
	if is_dead: return
	
	current_health -= amount
	if health_bar: health_bar.health = current_health
	
	if current_health <= 0:
		die()
	else:
		is_acting = true
		_play_animation("hit")
		await get_tree().create_timer(0.4).timeout
		if !is_dead: is_acting = false

func die():
	is_dead = true
	is_acting = true
	velocity = Vector2.ZERO
	_play_animation("death")
	boss_defeated.emit()

func _play_animation(anim_name: String):
	if anim_player and anim_player.has_animation(anim_name):
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name)
	elif anim_sprite and anim_sprite.sprite_frames.has_animation(anim_name):
		if anim_sprite.animation != anim_name:
			anim_sprite.play(anim_name)

func _has_animation(anim_name: String) -> bool:
	if anim_player: return anim_player.has_animation(anim_name)
	if anim_sprite: return anim_sprite.sprite_frames.has_animation(anim_name)
	return false

# --- SIGNAL HANDLERS ---

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
	else:
		is_acting = false

func _on_animated_sprite_2d_animation_finished() -> void:
	var current_anim: String = ""
	if anim_sprite: current_anim = anim_sprite.animation
	
	if current_anim == "death":
		queue_free()
	else:
		is_acting = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		is_acting = false # Reset so he can chase immediately if re-entered

func set_hitbox(active: bool):
	if has_node("Hitbox"):
		$Hitbox.set_deferred("monitoring", active)
	if active == false:
		is_acting = false
