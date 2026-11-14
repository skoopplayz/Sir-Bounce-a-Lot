extends Area2D
class_name PendulumHazard

# Swinging Inflatable Spiked Ball Pendulum
# Rhythmic swinging obstacle with cute soft spikes

@export var length: float = 160.0
@export var max_swing_angle: float = 0.95 # ~55 degrees
@export var swing_speed: float = 2.4
@export var ball_radius: float = 26.0

var current_angle: float = 0.0
var time_passed: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Colors
var ball_color: Color = Color(0.92, 0.28, 0.38, 1.0)
var spike_color: Color = Color(1.0, 0.88, 0.25, 1.0)
var rope_color: Color = Color(0.3, 0.25, 0.35, 1.0)
var outline_col: Color = Color(0.2, 0.15, 0.22, 1.0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	time_passed += delta * swing_speed
	current_angle = sin(time_passed) * max_swing_angle
	
	var ball_pos = Vector2(sin(current_angle) * length, cos(current_angle) * length)
	if collision_shape:
		collision_shape.position = ball_pos
		
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body is Prince:
		body.take_damage(global_position + collision_shape.position)

func _draw() -> void:
	var ball_pos = Vector2(sin(current_angle) * length, cos(current_angle) * length)
	
	# Top Anchor Pin
	draw_circle(Vector2.ZERO, 7.0, outline_col)
	draw_circle(Vector2.ZERO, 5.0, spike_color)
	
	# Elastic Rope
	draw_line(Vector2.ZERO, ball_pos, outline_col, 5.0)
	draw_line(Vector2.ZERO, ball_pos, rope_color, 3.0)
	
	# Inflatable Soft Spikes around ball
	var total_spikes = 8
	for i in range(total_spikes):
		var a = (float(i) / float(total_spikes)) * 2.0 * PI
		var spike_tip = ball_pos + Vector2(cos(a) * (ball_radius + 10.0), sin(a) * (ball_radius + 10.0))
		var b1 = ball_pos + Vector2(cos(a - 0.2) * ball_radius, sin(a - 0.2) * ball_radius)
		var b2 = ball_pos + Vector2(cos(a + 0.2) * ball_radius, sin(a + 0.2) * ball_radius)
		var s_pts = PackedVector2Array([b1, spike_tip, b2])
		draw_colored_polygon(s_pts, spike_color)
		draw_polyline(s_pts, outline_col, 2.0)
	
	# Ball Body
	draw_circle(ball_pos, ball_radius + 2.0, outline_col)
	draw_circle(ball_pos, ball_radius, ball_color)
	
	# Cute angry eyes on the spike-ball (Snipperclips charm!)
	draw_circle(ball_pos + Vector2(-6, -2), 4.0, Color.WHITE)
	draw_circle(ball_pos + Vector2(6, -2), 4.0, Color.WHITE)
	draw_circle(ball_pos + Vector2(-6, -2), 2.0, outline_col)
	draw_circle(ball_pos + Vector2(6, -2), 2.0, outline_col)
	# Determined eyebrows
	draw_line(ball_pos + Vector2(-9, -8), ball_pos + Vector2(-3, -5), outline_col, 2.0)
	draw_line(ball_pos + Vector2(9, -8), ball_pos + Vector2(3, -5), outline_col, 2.0)
