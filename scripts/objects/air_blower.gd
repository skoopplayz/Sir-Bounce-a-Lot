extends Area2D
class_name AirBlower

# Inflatable Air Vent / Wind Updraft
# Floats the Prince and bouncy objects upward through vertical shafts

@export var lift_force: float = 1850.0
@export var stream_height: float = 280.0
@export var vent_width: float = 90.0

@onready var particles: CPUParticles2D = $Particles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Setup collision shape based on stream height
	var rect = RectangleShape2D.new()
	rect.size = Vector2(vent_width, stream_height)
	collision_shape.shape = rect
	collision_shape.position = Vector2(0, -stream_height * 0.5)
	
	if particles:
		particles.position = Vector2(0, 0)
		particles.emission_rect_extents = Vector2(vent_width * 0.45, 4)
		particles.initial_velocity_min = lift_force * 0.25
		particles.initial_velocity_max = lift_force * 0.35
		
	queue_redraw()

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is Prince:
			# Float player upward, dampen horizontal drift slightly
			body.velocity.y = move_toward(body.velocity.y, -480.0, lift_force * delta)
		elif body is RigidBody2D:
			body.apply_central_force(Vector2.UP.rotated(rotation) * lift_force * 1.5)

func _draw() -> void:
	var hw = vent_width * 0.5
	# Vent pipe base
	draw_rect(Rect2(-hw, -10, vent_width, 20), Color(0.28, 0.25, 0.32, 1.0))
	draw_rect(Rect2(-hw + 4, -8, vent_width - 8, 16), Color(0.95, 0.8, 0.2, 1.0))
	
	# Translucent wind column
	var wind_rect = Rect2(-hw, -stream_height, vent_width, stream_height)
	draw_rect(wind_rect, Color(0.8, 0.95, 1.0, 0.12))
	
	# Wind arrows / guide lines
	draw_line(Vector2(-hw * 0.5, 0), Vector2(-hw * 0.5, -stream_height), Color(1.0, 1.0, 1.0, 0.25), 2.0)
	draw_line(Vector2(hw * 0.5, 0), Vector2(hw * 0.5, -stream_height), Color(1.0, 1.0, 1.0, 0.25), 2.0)
