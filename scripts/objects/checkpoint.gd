extends Area2D
class_name Checkpoint

# Checkpoint Banner for Sir Bounce a Lot
# When Prince touches it, unrolls with elastic spring bounce,
# flashes bright royal colors, emits star sparkles, and sets respawn point!

var is_activated: bool = false
var flag_wave: float = 0.0
var flag_spring: float = 0.0
var flag_spring_v: float = 0.0

@onready var particles: CPUParticles2D = $Particles

# Colors
var pole_color: Color = Color(0.24, 0.18, 0.28, 1.0)
var finial_gold: Color = Color(1.0, 0.88, 0.25, 1.0)
var unactive_flag: Color = Color(0.72, 0.65, 0.82, 0.85) # Sleepy lavender
var active_flag: Color = Color(0.25, 0.82, 0.88, 1.0)   # Vibrant royal turquoise
var active_trim: Color = Color(1.0, 0.85, 0.2, 1.0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	flag_wave += delta * (7.0 if is_activated else 2.5)
	
	# Elastic spring animation on activation
	if is_activated:
		var disp = 1.0 - flag_spring
		flag_spring_v += (disp * 320.0 - flag_spring_v * 18.0) * delta
		flag_spring += flag_spring_v * delta
	
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
	if body is Prince:
		activate()

func activate() -> void:
	is_activated = true
	flag_spring = 0.2
	flag_spring_v = 14.0
	
	if particles:
		particles.restart()
		particles.emitting = true
	
	# Register checkpoint position with GameManager (offset so player lands on ground safely)
	GameManager.register_checkpoint(global_position + Vector2(0, -10))
	queue_redraw()

func _draw() -> void:
	var h = 95.0
	
	# Base cushion
	draw_circle(Vector2(0, 4), 18.0, pole_color)
	draw_circle(Vector2(0, 2), 15.0, finial_gold if is_activated else unactive_flag)
	
	# Pole
	draw_line(Vector2(0, 0), Vector2(0, -h), pole_color, 5.0)
	
	# Pole stripes
	for i in range(5):
		var y1 = -float(i) * 16.0 - 10.0
		draw_line(Vector2(-2, y1), Vector2(2, y1 - 4), finial_gold, 2.5)
	
	# Top Finial Golden Star/Ball
	draw_circle(Vector2(0, -h), 9.0, pole_color)
	draw_circle(Vector2(0, -h), 7.0, finial_gold)
	
	# Banner / Pennant
	var flag_len = 54.0 * (flag_spring if is_activated else 0.7)
	var flag_h = 36.0
	var wave = sin(flag_wave) * (6.0 if is_activated else 2.0)
	
	var cur_col = active_flag if is_activated else unactive_flag
	
	var pts = PackedVector2Array([
		Vector2(2, -h + 6),
		Vector2(flag_len, -h + 6 + wave * 0.5),
		Vector2(flag_len * 0.75, -h + 6 + flag_h * 0.5 + wave),
		Vector2(flag_len, -h + 6 + flag_h + wave * 0.5),
		Vector2(2, -h + 6 + flag_h)
	])
	
	draw_colored_polygon(pts, cur_col)
	pts.append(pts[0])
	draw_polyline(pts, pole_color, 2.2)
	
	# Cute Face on the Banner (Snipperclips charm!)
	var face_center = Vector2(flag_len * 0.45, -h + 6 + flag_h * 0.5 + wave * 0.6)
	if is_activated:
		# Happy open eyes (^_^)
		draw_arc(face_center + Vector2(-6, -3), 4.0, PI + 0.3, 2.0 * PI - 0.3, 8, pole_color, 2.0)
		draw_arc(face_center + Vector2(6, -3), 4.0, PI + 0.3, 2.0 * PI - 0.3, 8, pole_color, 2.0)
		# Rosy cheeks
		draw_circle(face_center + Vector2(-9, 3), 2.5, Color(1.0, 0.4, 0.55, 0.8))
		draw_circle(face_center + Vector2(9, 3), 2.5, Color(1.0, 0.4, 0.55, 0.8))
		# Happy smile
		draw_arc(face_center + Vector2(0, 3), 3.5, 0.2, PI - 0.2, 8, pole_color, 2.0)
	else:
		# Sleepy closed eyes (-.-)
		draw_line(face_center + Vector2(-8, -2), face_center + Vector2(-3, -2), pole_color, 2.0)
		draw_line(face_center + Vector2(3, -2), face_center + Vector2(8, -2), pole_color, 2.0)
		# Small 'o' mouth
		draw_circle(face_center + Vector2(0, 3), 2.0, pole_color)
