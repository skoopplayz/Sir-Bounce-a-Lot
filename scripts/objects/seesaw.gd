extends Node2D
class_name Seesaw

# Interactive Physics Seesaw / Catapult
# When Prince or a bouncy ball ground-pounds or lands on one side,
# the opposite side catapults upwards with massive kinetic velocity!

@export var plank_length: float = 240.0
@export var plank_height: float = 14.0
@export var max_angle: float = 0.42 # In radians (~24 degrees)
@export var plank_color: Color = Color(0.96, 0.42, 0.48, 1.0) # Inflatable coral pink
@export var fulcrum_color: Color = Color(0.25, 0.2, 0.28, 1.0)

var current_angle: float = 0.0
var angular_velocity: float = 0.0
const ROTATIONAL_STIFFNESS: float = 18.0
const ROTATIONAL_DAMPING: float = 6.0

@onready var left_pad: Area2D = $LeftPad
@onready var right_pad: Area2D = $RightPad
@onready var solid_body: StaticBody2D = $SolidBody
@onready var solid_col: CollisionPolygon2D = $SolidBody/CollisionPolygon2D

func _ready() -> void:
	left_pad.body_entered.connect(_on_left_pad_entered)
	right_pad.body_entered.connect(_on_right_pad_entered)
	_update_pad_positions()
	queue_redraw()

func _physics_process(delta: float) -> void:
	# Rotational spring recovery towards resting angle
	var torque = -current_angle * ROTATIONAL_STIFFNESS - angular_velocity * ROTATIONAL_DAMPING
	angular_velocity += torque * delta
	current_angle += angular_velocity * delta
	
	current_angle = clamp(current_angle, -max_angle, max_angle)
	if abs(current_angle) >= max_angle:
		angular_velocity = 0.0
		
	_update_pad_positions()
	queue_redraw()

func _update_pad_positions() -> void:
	var half_len = plank_length * 0.5
	var left_pos = Vector2(-half_len, 0).rotated(current_angle)
	var right_pos = Vector2(half_len, 0).rotated(current_angle)
	
	if left_pad:
		left_pad.position = left_pos
	if right_pad:
		right_pad.position = right_pos
		
	if solid_col:
		var w = plank_length * 0.5
		var h = plank_height * 0.5
		var p1 = Vector2(-w, -h).rotated(current_angle)
		var p2 = Vector2(w, -h).rotated(current_angle)
		var p3 = Vector2(w, h).rotated(current_angle)
		var p4 = Vector2(-w, h).rotated(current_angle)
		solid_col.polygon = PackedVector2Array([p1, p2, p3, p4])

func _on_left_pad_entered(body: Node2D) -> void:
	_trigger_seesaw_impact(body, -1.0)

func _on_right_pad_entered(body: Node2D) -> void:
	_trigger_seesaw_impact(body, 1.0)

func _trigger_seesaw_impact(impactor: Node2D, side_dir: float) -> void:
	# side_dir: -1 for left pad, +1 for right pad
	var is_ground_pound = false
	var impact_power = 600.0
	
	if impactor is Prince:
		if impactor.is_ground_pounding:
			is_ground_pound = true
			impact_power = 1200.0
			GameManager.request_camera_shake(8.0, 0.3)
	
	# Apply angular force
	angular_velocity += side_dir * (impact_power * 0.02)
	SoundManager.play_super_bounce()
	
	# Catapult anything sitting on the OPPOSITE pad!
	var opposite_pad = right_pad if side_dir < 0.0 else left_pad
	var bodies = opposite_pad.get_overlapping_bodies()
	for b in bodies:
		if b != impactor:
			var launch_h = -920.0 if is_ground_pound else -680.0
			var launch_x = -side_dir * 220.0
			if b is Prince:
				b.bounce_off_surface(Vector2(launch_x, launch_h), true)
			elif b is RigidBody2D:
				b.linear_velocity = Vector2(launch_x, launch_h * 1.2)

func _draw() -> void:
	# 1. Fulcrum Base Triangle
	var fulcrum_pts = PackedVector2Array([
		Vector2(0, 0),
		Vector2(-24, 32),
		Vector2(24, 32)
	])
	draw_colored_polygon(fulcrum_pts, fulcrum_color)
	draw_polyline(fulcrum_pts, Color(0.15, 0.1, 0.18, 1.0), 2.5)
	
	# 2. Rotating Plank
	var half_len = plank_length * 0.5
	var half_h = plank_height * 0.5
	var p1 = Vector2(-half_len, -half_h).rotated(current_angle)
	var p2 = Vector2(half_len, -half_h).rotated(current_angle)
	var p3 = Vector2(half_len, half_h).rotated(current_angle)
	var p4 = Vector2(-half_len, half_h).rotated(current_angle)
	
	var plank_pts = PackedVector2Array([p1, p2, p3, p4])
	draw_colored_polygon(plank_pts, plank_color)
	plank_pts.append(p1)
	draw_polyline(plank_pts, Color(0.2, 0.15, 0.22, 1.0), 2.5)
	
	# Catapult Target Pads on each end
	var left_pt = Vector2(-half_len + 18, -half_h).rotated(current_angle)
	var right_pt = Vector2(half_len - 18, -half_h).rotated(current_angle)
	draw_circle(left_pt, 10.0, Color(1.0, 0.88, 0.25, 1.0))
	draw_circle(right_pt, 10.0, Color(1.0, 0.88, 0.25, 1.0))
	
	# Fulcrum Center Bolt
	draw_circle(Vector2(0, 0), 6.0, Color(1.0, 0.88, 0.25, 1.0))
	draw_circle(Vector2(0, 0), 3.0, Color(0.2, 0.15, 0.22, 1.0))
