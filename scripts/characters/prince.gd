extends CharacterBody2D
class_name Prince

# Main Player Controller for Sir Bounce a Lot
# Handles platforming physics, soft-body squash & stretch spring math,
# super-bounce charging, ground pound, and trampoline interactions.

signal bounced(intensity: float, is_perfect: bool)

@export var move_speed: float = 340.0
@export var acceleration: float = 2400.0
@export var friction: float = 1900.0
@export var air_control: float = 1400.0
@export var jump_velocity: float = -580.0
@export var gravity: float = 1200.0

# Super Bounce Charge variables
var charge_time: float = 0.0
const MAX_CHARGE_TIME: float = 0.85
const SUPER_BOUNCE_MAX_VELOCITY: float = -1050.0
var is_charging: bool = false

# Ground Pound variables
var is_ground_pounding: bool = false
const GROUND_POUND_SPEED: float = 1050.0

# Squash & Stretch Spring Variables
var squash_stretch: Vector2 = Vector2.ONE
var squash_velocity: Vector2 = Vector2.ZERO
const SPRING_CONSTANT: float = 320.0
const DAMPING: float = 22.0

# Rhythmic Perfect Bounce timing buffer
var contact_timer: float = 0.0
var can_perfect_bounce: bool = false

# Node references
@onready var visual: Node2D = $Visual
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles_burst: CPUParticles2D = $ParticlesBurst
@onready var particles_charge: CPUParticles2D = $ParticlesCharge

var invulnerable_timer: float = 0.0
var is_invulnerable: bool = false
var fall_limit_y: float = 950.0
var is_respawning: bool = false

func _ready() -> void:
	add_to_group("player")
	GameManager.default_spawn_position = global_position

func _physics_process(delta: float) -> void:
	# Fall limit check (respawn at checkpoint if fallen)
	if global_position.y > fall_limit_y and not is_respawning:
		on_fall_death()
		return
	# Invulnerability cooldown
	if is_invulnerable:
		invulnerable_timer -= delta
		visual.modulate.a = 0.4 if fmod(invulnerable_timer * 15.0, 1.0) > 0.5 else 1.0
		if invulnerable_timer <= 0.0:
			is_invulnerable = false
			visual.modulate.a = 1.0

	# 1. Horizontal Movement & Input
	var input_x = 0.0
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_x -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_x += 1.0

	var is_crouch_pressed = Input.is_action_pressed("crouch_charge") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

	# 2. State & Mechanics Handling
	if is_on_floor():
		is_ground_pounding = false
		
		# Charging Super Bounce
		if is_crouch_pressed and not is_charging:
			is_charging = true
			charge_time = 0.0
			SoundManager.play_charge()
			particles_charge.emitting = true
			
		elif is_charging:
			if is_crouch_pressed:
				charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
				# Decelerate horizontally while crouch charging
				velocity.x = move_toward(velocity.x, 0.0, friction * delta)
				# Flatten squash visually proportional to charge
				var charge_ratio = charge_time / MAX_CHARGE_TIME
				squash_stretch = Vector2(1.0 + charge_ratio * 0.55, 1.0 - charge_ratio * 0.45)
			else:
				# Released crouch -> Unleash Super Bounce!
				_release_super_bounce()
		else:
			# Normal Ground Movement
			if input_x != 0.0:
				velocity.x = move_toward(velocity.x, input_x * move_speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, friction * delta)

			# Regular Jump
			if Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
				_do_jump(jump_velocity, false)
	else:
		# Air Physics
		is_charging = false
		particles_charge.emitting = false
		
		# Ground Pound initiation
		if is_crouch_pressed and not is_ground_pounding and velocity.y > -200.0:
			is_ground_pounding = true
			velocity.y = GROUND_POUND_SPEED
			velocity.x = 0.0
			SoundManager.play_ground_pound()
			apply_squash_stretch(0.65, 1.45)
		
		if not is_ground_pounding:
			# Normal gravity & air acceleration
			velocity.y += gravity * delta
			if input_x != 0.0:
				velocity.x = move_toward(velocity.x, input_x * move_speed, air_control * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, air_control * 0.3 * delta)
		else:
			# Fast downward ground pound
			velocity.y = GROUND_POUND_SPEED
			velocity.x = 0.0

	# 3. Handle Perfect Bounce Buffer Window
	if contact_timer > 0.0:
		contact_timer -= delta
		if contact_timer <= 0.0:
			can_perfect_bounce = false

	# 4. Move and Slide
	var was_in_air = not is_on_floor()
	var pre_fall_speed = velocity.y
	move_and_slide()

	# Landing Impact Squash
	if was_in_air and is_on_floor():
		var impact_intensity = clamp(pre_fall_speed / 800.0, 0.1, 0.8)
		apply_squash_stretch(1.0 + impact_intensity * 0.7, 1.0 - impact_intensity * 0.55)
		
		if is_ground_pounding:
			is_ground_pounding = false
			SoundManager.play_ground_pound()
			GameManager.request_camera_shake(10.0, 0.35)
			spawn_impact_burst()
			_check_ground_pound_targets()

	# 5. Spring Physics Update for Visual Squash/Stretch
	_update_spring_physics(delta)

	# 6. Update Snipperclips Visuals
	var charge_ratio = (charge_time / MAX_CHARGE_TIME) if is_charging else 0.0
	visual.update_visual_state(velocity, is_on_floor(), is_charging, is_ground_pounding, charge_ratio)

func _release_super_bounce() -> void:
	is_charging = false
	particles_charge.emitting = false
	var ratio = charge_time / MAX_CHARGE_TIME
	if ratio >= 0.25:
		var bounce_pwr = lerp(jump_velocity * 1.15, SUPER_BOUNCE_MAX_VELOCITY, ratio)
		_do_jump(bounce_pwr, true)
		SoundManager.play_super_bounce()
		spawn_impact_burst()
		GameManager.request_camera_shake(6.0 * ratio, 0.25)
	else:
		# Cancelled or tiny charge -> regular jump
		_do_jump(jump_velocity, false)
	charge_time = 0.0

func _do_jump(launch_vel: float, is_super: bool) -> void:
	velocity.y = launch_vel
	if is_super:
		apply_squash_stretch(0.65, 1.55)
	else:
		apply_squash_stretch(0.75, 1.35)
		SoundManager.play_jump()

func bounce_off_surface(impulse_vector: Vector2, is_trampoline: bool = false) -> void:
	# Check if player timed a Perfect Bounce
	var is_perfect = false
	if is_trampoline and (Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)):
		is_perfect = true
		impulse_vector *= 1.45
		SoundManager.play_super_bounce()
		spawn_impact_burst()
		GameManager.add_ring(3) # Bonus reward!
	else:
		SoundManager.play_jump()

	velocity = impulse_vector
	apply_squash_stretch(0.6, 1.5)
	emit_signal("bounced", impulse_vector.length(), is_perfect)

func bounce_from_bumper(impulse_vector: Vector2) -> void:
	velocity = impulse_vector
	apply_squash_stretch(1.4, 0.6)
	SoundManager.play_bumper()
	spawn_impact_burst()
	GameManager.request_camera_shake(5.0, 0.2)

func apply_squash_stretch(scale_x: float, scale_y: float) -> void:
	squash_stretch = Vector2(scale_x, scale_y)

func _update_spring_physics(delta: float) -> void:
	if not is_charging:
		var displacement = Vector2.ONE - squash_stretch
		var spring_force = displacement * SPRING_CONSTANT
		var damping_force = -squash_velocity * DAMPING
		squash_velocity += (spring_force + damping_force) * delta
		squash_stretch += squash_velocity * delta
	
	visual.scale = squash_stretch

func take_damage(from_pos: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or is_respawning:
		return
	
	is_invulnerable = true
	invulnerable_timer = 1.6
	
	# Knockback
	var knock_dir = (global_position - from_pos).normalized() if from_pos != Vector2.ZERO else Vector2.UP
	velocity = (knock_dir + Vector2.UP).normalized() * 520.0
	apply_squash_stretch(1.3, 0.7)
	GameManager.handle_player_fall_or_death(self)

func on_fall_death() -> void:
	if is_respawning:
		return
	is_respawning = true
	velocity = Vector2.ZERO
	GameManager.handle_player_fall_or_death(self)

func respawn_at(target_pos: Vector2) -> void:
	global_position = target_pos
	velocity = Vector2(0, -280) # Gentle return bounce
	is_respawning = false
	is_ground_pounding = false
	is_charging = false
	is_invulnerable = true
	invulnerable_timer = 2.2 # Safe invulnerability window
	apply_squash_stretch(0.65, 1.45)
	SoundManager.play_super_bounce()
	spawn_impact_burst()

func spawn_impact_burst() -> void:
	if particles_burst:
		particles_burst.restart()
		particles_burst.emitting = true

func _check_ground_pound_targets() -> void:
	# Detect any ground pound targets, breakables or bosses nearby
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 48.0
	query.shape = circle
	query.transform = Transform2D(0.0, global_position + Vector2(0, 20))
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	for r in results:
		var collider = r.collider
		if collider and collider.has_method("on_ground_pounded"):
			collider.on_ground_pounded(self)
		elif collider and collider.get_parent() and collider.get_parent().has_method("on_ground_pounded"):
			collider.get_parent().on_ground_pounded(self)
