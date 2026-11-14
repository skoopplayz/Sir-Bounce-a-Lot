extends Node2D
class_name Princess

# Princess Aurelia - Trapped in the Bouncy Castle
# snipperclips aesthetic: soft pillow shape, tiara, big sparkling eyes, cheering animations,
# floating heart particles, and inflatable bubble cage physics.

@export var is_caged: bool = true
var is_rescued: bool = false
var cheer_timer: float = 0.0
var blink_timer: float = 2.0
var is_blinking: bool = false
var float_offset: float = 0.0

@onready var heart_particles: CPUParticles2D = $HeartParticles

# Colors
var body_color: Color = Color(0.35, 0.88, 0.82, 1.0) # Lovely pastel mint/cyan
var body_shadow_color: Color = Color(0.2, 0.7, 0.65, 1.0)
var dress_pink: Color = Color(1.0, 0.45, 0.68, 1.0)
var tiara_gold: Color = Color(1.0, 0.88, 0.22, 1.0)
var outline_col: Color = Color(0.18, 0.15, 0.22, 1.0)
var blush_col: Color = Color(1.0, 0.35, 0.5, 0.5)

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	cheer_timer += delta * 4.0
	float_offset = sin(cheer_timer) * 6.0
	
	# Blinking
	blink_timer -= delta
	if blink_timer <= 0.0:
		if is_blinking:
			is_blinking = false
			blink_timer = randf_range(2.0, 4.5)
		else:
			is_blinking = true
			blink_timer = 0.12
	
	queue_redraw()

func free_from_cage() -> void:
	is_caged = false
	is_rescued = true
	SoundManager.play_pop()
	SoundManager.play_victory()
	if heart_particles:
		heart_particles.emitting = true
	queue_redraw()

func _draw() -> void:
	var root_pos = Vector2(0, float_offset)
	
	# Inflatable Bubble Cage if caged
	if is_caged:
		_draw_bubble_cage(root_pos)
		
	# Drop shadow
	draw_circle(Vector2(0, 30), 22, Color(0.1, 0.1, 0.15, 0.2))
	
	# Ribbon Bow
	_draw_ribbon(root_pos)
	
	# Pill Body
	var radius = 24.0
	draw_circle(root_pos, radius + 2.0, outline_col)
	draw_circle(root_pos, radius, body_color)
	draw_arc(root_pos, radius - 3.5, 0.2, PI - 0.2, 16, body_shadow_color, 3.5)
	
	# Glossy highlight
	var shine_pos = root_pos + Vector2(-radius * 0.35, -radius * 0.35)
	_draw_ellipse(shine_pos, 8.0, 5.0, -0.4, Color(1.0, 1.0, 1.0, 0.6))
	
	# Golden Tiara
	_draw_tiara(root_pos)
	
	# Expressive Eyes with Eyelashes
	_draw_eyes(root_pos)
	
	# Cute Mouth & Cheeks
	_draw_face(root_pos)

func _draw_bubble_cage(pos: Vector2) -> void:
	var cage_radius = 42.0
	# Translucent bubble
	draw_circle(pos, cage_radius, Color(0.8, 0.95, 1.0, 0.35))
	draw_arc(pos, cage_radius, 0.0, 2.0 * PI, 32, Color(0.6, 0.88, 1.0, 0.8), 2.5)
	# Bubble reflection arc
	draw_arc(pos, cage_radius - 6.0, PI * 1.1, PI * 1.6, 12, Color(1.0, 1.0, 1.0, 0.7), 3.0)

func _draw_ribbon(pos: Vector2) -> void:
	var bow_pos = pos + Vector2(0, 18)
	var pts1 = PackedVector2Array([bow_pos, bow_pos + Vector2(-12, -6), bow_pos + Vector2(-12, 6)])
	var pts2 = PackedVector2Array([bow_pos, bow_pos + Vector2(12, -6), bow_pos + Vector2(12, 6)])
	draw_colored_polygon(pts1, dress_pink)
	draw_polyline(pts1, outline_col, 1.8)
	draw_colored_polygon(pts2, dress_pink)
	draw_polyline(pts2, outline_col, 1.8)
	draw_circle(bow_pos, 3.5, dress_pink)

func _draw_tiara(pos: Vector2) -> void:
	var tiara_base = pos + Vector2(0, -22)
	var pts = PackedVector2Array([
		tiara_base + Vector2(-12, 0),
		tiara_base + Vector2(-10, -10),
		tiara_base + Vector2(-4, -5),
		tiara_base + Vector2(0, -14),
		tiara_base + Vector2(4, -5),
		tiara_base + Vector2(10, -10),
		tiara_base + Vector2(12, 0)
	])
	draw_colored_polygon(pts, tiara_gold)
	pts.append(pts[0])
	draw_polyline(pts, outline_col, 2.0)
	draw_circle(tiara_base + Vector2(0, -12), 2.0, dress_pink)

func _draw_eyes(pos: Vector2) -> void:
	var eye_y = -3.0
	var left_eye = pos + Vector2(-8, eye_y)
	var right_eye = pos + Vector2(8, eye_y)
	
	if is_rescued:
		# Happy smiling eyes (^_^)
		draw_arc(left_eye, 5.5, PI + 0.3, 2.0 * PI - 0.3, 10, outline_col, 2.5)
		draw_arc(right_eye, 5.5, PI + 0.3, 2.0 * PI - 0.3, 10, outline_col, 2.5)
		return
	
	if is_blinking:
		draw_line(left_eye + Vector2(-5, 0), left_eye + Vector2(5, 0), outline_col, 2.2)
		draw_line(right_eye + Vector2(-5, 0), right_eye + Vector2(5, 0), outline_col, 2.2)
		return
		
	# Big sparkling cute anime/Snipperclips eyes
	_draw_ellipse(left_eye, 6.5, 8.5, 0.0, Color.WHITE)
	_draw_ellipse_outline(left_eye, 6.5, 8.5, 0.0, outline_col, 2.0)
	_draw_ellipse(right_eye, 6.5, 8.5, 0.0, Color.WHITE)
	_draw_ellipse_outline(right_eye, 6.5, 8.5, 0.0, outline_col, 2.0)
	
	# Eyelashes
	draw_line(left_eye + Vector2(-5, -7), left_eye + Vector2(-8, -10), outline_col, 1.8)
	draw_line(right_eye + Vector2(5, -7), right_eye + Vector2(8, -10), outline_col, 1.8)
	
	# Pupils
	draw_circle(left_eye + Vector2(0, 1), 3.8, outline_col)
	draw_circle(left_eye + Vector2(1.2, -0.8), 1.6, Color.WHITE)
	draw_circle(right_eye + Vector2(0, 1), 3.8, outline_col)
	draw_circle(right_eye + Vector2(1.2, -0.8), 1.6, Color.WHITE)

func _draw_face(pos: Vector2) -> void:
	# Blushing cheeks
	_draw_ellipse(pos + Vector2(-15, 5), 4.0, 2.5, 0.0, blush_col)
	_draw_ellipse(pos + Vector2(15, 5), 4.0, 2.5, 0.0, blush_col)
	
	var mouth = pos + Vector2(0, 7)
	if is_rescued:
		# Grinning happy mouth
		draw_arc(mouth, 5.0, 0.3, PI - 0.3, 10, outline_col, 2.2)
	else:
		# Pouting cute "o" pleading for rescue
		_draw_ellipse(mouth + Vector2(0, 1), 2.5, 3.5, 0.0, outline_col)

func _draw_ellipse(pos: Vector2, rx: float, ry: float, rot: float, col: Color) -> void:
	var pts = PackedVector2Array()
	var segs = 14
	for i in range(segs):
		var a = (float(i) / float(segs)) * 2.0 * PI
		pts.append(Vector2(cos(a) * rx, sin(a) * ry).rotated(rot) + pos)
	draw_colored_polygon(pts, col)

func _draw_ellipse_outline(pos: Vector2, rx: float, ry: float, rot: float, col: Color, width: float) -> void:
	var pts = PackedVector2Array()
	var segs = 14
	for i in range(segs + 1):
		var a = (float(i % segs) / float(segs)) * 2.0 * PI
		pts.append(Vector2(cos(a) * rx, sin(a) * ry).rotated(rot) + pos)
	draw_polyline(pts, col, width)
