extends Area2D
class_name PinballBumper

# Reactive Pinball Bumper with Snipperclips / Carnival bouncy aesthetic
# Flashes neon, delivers radial impulse launch, and bursts sparkles.

@export var bounce_strength: float = 720.0
@export var bumper_radius: float = 34.0
@export var base_color: Color = Color(0.98, 0.45, 0.15, 1.0) # Radiant tangerine
@export var rim_color: Color = Color(1.0, 0.88, 0.25, 1.0)

var pulse_scale: float = 1.0
var flash_timer: float = 0.0
var is_flashing: bool = false

@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	pulse_scale = lerp(pulse_scale, 1.0, 14.0 * delta)
	if is_flashing:
		flash_timer -= delta
		if flash_timer <= 0.0:
			is_flashing = false
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	# Calculate radial impulse vector from bumper center to body
	var dir = (body.global_position - global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.UP
		
	# Bumper animation trigger
	pulse_scale = 1.45
	is_flashing = true
	flash_timer = 0.25
	
	if particles:
		particles.restart()
		particles.emitting = true
		
	if body is Prince:
		body.bounce_from_bumper(dir * bounce_strength)
		GameManager.add_ring(1) # Bumping gives a point!
	elif body is RigidBody2D:
		body.linear_velocity = dir * bounce_strength * 1.3
		SoundManager.play_bumper()

func _draw() -> void:
	var r = bumper_radius * pulse_scale
	var cur_col = Color.WHITE if is_flashing else base_color
	
	# Drop shadow
	draw_circle(Vector2(0, 6), r + 2.0, Color(0.15, 0.1, 0.2, 0.2))
	
	# Outer bumper ring
	draw_circle(Vector2.ZERO, r + 3.0, Color(0.2, 0.15, 0.22, 1.0))
	draw_circle(Vector2.ZERO, r, cur_col)
	
	# Inner glowing concentric ring
	draw_arc(Vector2.ZERO, r * 0.65, 0.0, 2.0 * PI, 24, rim_color, 3.5)
	
	# Center golden star
	_draw_star(Vector2.ZERO, r * 0.42, r * 0.2, 5, rim_color)
	
	# Glossy highlight
	draw_circle(Vector2(-r * 0.35, -r * 0.35), r * 0.18, Color(1.0, 1.0, 1.0, 0.55))

func _draw_star(pos: Vector2, r_out: float, r_in: float, points: int, col: Color) -> void:
	var pts = PackedVector2Array()
	var total = points * 2
	for i in range(total):
		var a = (float(i) / float(total)) * 2.0 * PI - PI * 0.5
		var rad = r_out if (i % 2 == 0) else r_in
		pts.append(pos + Vector2(cos(a) * rad, sin(a) * rad))
	draw_colored_polygon(pts, col)
