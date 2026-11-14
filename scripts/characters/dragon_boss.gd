extends CharacterBody2D
class_name DragonBoss

# Final Boss: Ignis the Inflatable Dragon
# Multi-phase bouncy dragon boss with Snipperclips style visuals,
# bouncing fire-bubble attacks, belly ground-pound vulnerability, and comical deflation defeat!

signal boss_damaged(new_hp: int, max_hp: int)
signal boss_defeated()

@export var max_hp: int = 5
var current_hp: int = 5

enum State {
	HOVERING,
	CHARGING_FIRE,
	GROUND_STOMP,
	SWOOPING,
	STUNNED,
	DEFLATING_DEFEAT
}

var current_state: State = State.HOVERING
var state_timer: float = 0.0
var attack_cooldown: float = 2.5
var wing_flap_timer: float = 0.0
var swoop_dir: float = 1.0

# Movement bounds in boss arena
var arena_center_x: float = 640.0
var hover_y: float = 240.0
var move_dir: float = 1.0
var hover_speed: float = 130.0

# Fire bubble projectile scene
var fire_bubble_scene: PackedScene = preload("res://scenes/objects/fire_bubble.tscn")

# Snipperclips visual animation variables
var is_flashing: bool = false
var flash_timer: float = 0.0
var eyes_dizzy: bool = false
var deflation_spin: float = 0.0
var belly_squash: Vector2 = Vector2.ONE
var belly_squash_vel: Vector2 = Vector2.ZERO

@onready var visual: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var confetti_particles: CPUParticles2D = $ConfettiParticles

# Princess reference
@export var princess_node: NodePath

func _ready() -> void:
	add_to_group("boss")
	current_hp = max_hp
	arena_center_x = global_position.x
	hover_y = global_position.y
	emit_signal("boss_damaged", current_hp, max_hp)

func _physics_process(delta: float) -> void:
	wing_flap_timer += delta * (8.0 if current_hp > 2 else 12.0)
	
	# Damage flash
	if is_flashing:
		flash_timer -= delta
		visual.modulate = Color(1.0, 0.4, 0.4, 1.0) if fmod(flash_timer * 12.0, 1.0) > 0.5 else Color.WHITE
		if flash_timer <= 0.0:
			is_flashing = false
			visual.modulate = Color.WHITE

	# Belly spring relaxation
	var disp = Vector2.ONE - belly_squash
	belly_squash_vel += (disp * 280.0 - belly_squash_vel * 18.0) * delta
	belly_squash += belly_squash_vel * delta

	match current_state:
		State.HOVERING:
			_process_hovering(delta)
		State.CHARGING_FIRE:
			_process_charging_fire(delta)
		State.GROUND_STOMP:
			_process_ground_stomp(delta)
		State.SWOOPING:
			_process_swooping(delta)
		State.STUNNED:
			_process_stunned(delta)
		State.DEFLATING_DEFEAT:
			_process_deflation(delta)

	visual.queue_redraw()

func _process_hovering(delta: float) -> void:
	# Sinusoidal hover motion
	global_position.x += move_dir * hover_speed * delta
	global_position.y = hover_y + sin(wing_flap_timer * 0.5) * 25.0
	
	if abs(global_position.x - arena_center_x) > 380.0:
		move_dir = -sign(global_position.x - arena_center_x)

	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		if current_hp <= 2 and randf() > 0.5:
			_start_swoop()
		elif randf() > 0.4:
			_start_fire_attack()
		else:
			_start_stomp()

func _start_fire_attack() -> void:
	current_state = State.CHARGING_FIRE
	state_timer = 0.9
	SoundManager.play_boss_roar()
	belly_squash = Vector2(1.3, 0.7)

func _process_charging_fire(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		# Shoot 1 to 3 bouncy fire bubbles
		var count = 3 if current_hp <= 2 else (2 if current_hp <= 3 else 1)
		for i in range(count):
			_spawn_fire_bubble(i - (count - 1) * 0.5)
		
		attack_cooldown = randf_range(2.0, 3.2)
		current_state = State.HOVERING

func _spawn_fire_bubble(spread_offset: float) -> void:
	if not fire_bubble_scene:
		return
	var b = fire_bubble_scene.instantiate()
	b.global_position = global_position + Vector2(0, 45)
	var shoot_angle = PI * 0.5 + spread_offset * 0.35
	var shoot_dir = Vector2(cos(shoot_angle), sin(shoot_angle))
	b.linear_velocity = shoot_dir * 380.0
	get_parent().add_child(b)
	SoundManager.play_pop()

func _start_stomp() -> void:
	current_state = State.GROUND_STOMP
	state_timer = 0.0
	belly_squash = Vector2(0.7, 1.4)

func _process_ground_stomp(delta: float) -> void:
	# Slam down rapidly
	global_position.y += 650.0 * delta
	if global_position.y >= hover_y + 190.0:
		# Impact floor!
		global_position.y = hover_y + 190.0
		SoundManager.play_ground_pound()
		GameManager.request_camera_shake(12.0, 0.4)
		belly_squash = Vector2(1.6, 0.5)
		
		# Return to hover
		current_state = State.HOVERING
		attack_cooldown = 2.0
		var tween = create_tween()
		tween.tween_property(self, "global_position:y", hover_y, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _start_swoop() -> void:
	current_state = State.SWOOPING
	state_timer = 2.2
	swoop_dir = 1.0 if global_position.x < arena_center_x else -1.0
	SoundManager.play_boss_roar()

func _process_swooping(delta: float) -> void:
	state_timer -= delta
	global_position.x += swoop_dir * 460.0 * delta
	global_position.y = hover_y + 120.0 + sin(state_timer * 4.0) * 60.0
	
	if state_timer <= 0.0 or abs(global_position.x - arena_center_x) > 420.0:
		current_state = State.HOVERING
		attack_cooldown = 2.2
		var tween = create_tween()
		tween.tween_property(self, "global_position:y", hover_y, 0.7)

func _process_stunned(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		eyes_dizzy = false
		current_state = State.HOVERING
		attack_cooldown = 1.5

func _process_deflation(delta: float) -> void:
	deflation_spin += delta * 18.0
	visual.rotation = deflation_spin
	visual.scale = visual.scale.move_toward(Vector2.ZERO, delta * 0.7)
	global_position += Vector2(cos(deflation_spin * 2.0) * 280.0, -180.0) * delta
	
	if visual.scale.x <= 0.05:
		_finish_defeat()

func on_ground_pounded(prince: Prince) -> void:
	# Player ground pounded dragon's belly/head!
	take_boss_hit(prince)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Prince:
		# If prince lands on top of dragon while moving downward, count as hit!
		if body.velocity.y > 50.0 and body.global_position.y < global_position.y - 10.0:
			take_boss_hit(body)
			body.bounce_off_surface(Vector2(0, -680))
		else:
			# Player collided with dragon body -> damage player
			body.take_damage(global_position)

func take_boss_hit(prince: Prince = null) -> void:
	if current_state == State.DEFLATING_DEFEAT or is_flashing:
		return
		
	current_hp -= 1
	emit_signal("boss_damaged", current_hp, max_hp)
	SoundManager.play_boss_hit()
	GameManager.request_camera_shake(10.0, 0.35)
	
	is_flashing = true
	flash_timer = 0.8
	eyes_dizzy = true
	belly_squash = Vector2(1.5, 0.5)
	
	if current_hp <= 0:
		_trigger_defeat()
	else:
		current_state = State.STUNNED
		state_timer = 1.2
		if current_hp <= 2:
			hover_speed = 190.0 # Enraged faster movement

func _trigger_defeat() -> void:
	current_state = State.DEFLATING_DEFEAT
	SoundManager.play_boss_defeat()
	GameManager.request_camera_shake(16.0, 0.6)
	if confetti_particles:
		confetti_particles.restart()
		confetti_particles.emitting = true
	
	# Free princess!
	if princess_node:
		var p = get_node_or_null(princess_node)
		if p and p.has_method("free_from_cage"):
			p.free_from_cage()

func _finish_defeat() -> void:
	emit_signal("boss_defeated")
	GameManager.complete_level()
	queue_free()
