extends Area2D
class_name Trampoline

# Inflatable Trampoline with responsive spring deformation
# Supports standard high bounce and player rhythmic "Perfect Bounce" timing

@export var bounce_power: float = 780.0
@export var width: float = 120.0
@export var pad_color: Color = Color(0.2, 0.85, 0.82, 1.0) # Inflatable turquoise
@export var rim_color: Color = Color(1.0, 0.88, 0.25, 1.0) # Yellow rim

var spring_compression: float = 0.0
var spring_velocity: float = 0.0
const SPRING_K: float = 340.0
const DAMP: float = 24.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	# Spring oscillation recovery
	var force = -spring_compression * SPRING_K - spring_velocity * DAMP
	spring_velocity += force * delta
	spring_compression += spring_velocity * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body is Prince:
		# Compress spring pad deeply
		spring_compression = 18.0
		spring_velocity = 80.0
		# Launch player upward
		var launch_vec = Vector2.UP.rotated(rotation) * bounce_power
		body.bounce_off_surface(launch_vec, true)
	elif body is RigidBody2D:
		body.apply_central_impulse(Vector2.UP.rotated(rotation) * bounce_power * 1.2)
		spring_compression = 14.0

func _draw() -> void:
	var hw = width * 0.5
	var center_y = spring_compression
	
	# Base supports / Spring coils
	var leg_col = Color(0.25, 0.2, 0.28, 1.0)
	draw_line(Vector2(-hw * 0.8, 4), Vector2(-hw * 0.8, 16), leg_col, 5.0)
	draw_line(Vector2(hw * 0.8, 4), Vector2(hw * 0.8, 16), leg_col, 5.0)
	
	# Trampoline Bed (curved down by compression)
	var bed_pts = PackedVector2Array()
	bed_pts.append(Vector2(-hw, 0))
	bed_pts.append(Vector2(0, center_y + 4.0))
	bed_pts.append(Vector2(hw, 0))
	draw_polyline(bed_pts, pad_color, 8.0)
	
	# Top Elastic Rim
	draw_line(Vector2(-hw, 0), Vector2(hw, 0), rim_color, 4.0)
	
	# End Padded Caps
	draw_circle(Vector2(-hw, 0), 6.0, rim_color)
	draw_circle(Vector2(hw, 0), 6.0, rim_color)
	draw_circle(Vector2(-hw, 0), 6.0, leg_col)
	draw_circle(Vector2(hw, 0), 6.0, leg_col)
