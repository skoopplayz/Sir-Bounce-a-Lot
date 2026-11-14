extends Node2D

# Snipperclips-style Reactive Character Visual for Prince Bounce-a-Lot
# Features:
# - Expressive googly/tracking eyes that look toward motion, widen on falling, squint happily on bounce
# - Reactive mouth shapes (happy, surprised "O", charging grin, dizzy)
# - Golden crown that tilts with momentum
# - Bouncy red royal cape that billows with velocity
# - Procedural anti-aliased drawing with soft drop shadow and glossy inflatable highlights

enum ExpressionState {
	NORMAL,
	CHARGING,
	BOUNCING_HIGH,
	FALLING_SCARED,
	GROUND_POUNDING,
	DIZZY
}

var expression: ExpressionState = ExpressionState.NORMAL
var look_direction: Vector2 = Vector2.RIGHT
var velocity_ref: Vector2 = Vector2.ZERO
var blink_timer: float = 0.0
var is_blinking: bool = false
var charge_progress: float = 0.0 # 0.0 to 1.0

# Cape physics
var cape_angle: float = 0.0
var cape_target_angle: float = 0.0

# Colors (Snipperclips vibrant pastel palette)
var body_color: Color = Color(0.98, 0.32, 0.44, 1.0) # Vibrant coral pink/red
var body_shadow_color: Color = Color(0.78, 0.18, 0.32, 1.0)
var crown_gold: Color = Color(1.0, 0.88, 0.22, 1.0)
var crown_outline: Color = Color(0.24, 0.14, 0.18, 1.0)
var eye_white: Color = Color(1.0, 1.0, 1.0, 1.0)
var eye_pupil: Color = Color(0.16, 0.12, 0.15, 1.0)
var blush_color: Color = Color(1.0, 0.2, 0.45, 0.45)
var cape_color: Color = Color(0.68, 0.15, 0.22, 0.9)

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	# Blinking logic
	blink_timer -= delta
	if blink_timer <= 0.0:
		if is_blinking:
			is_blinking = false
			blink_timer = randf_range(2.5, 5.0)
		else:
			is_blinking = true
			blink_timer = 0.12 # Quick blink
	
	# Cape physics simulation
	cape_target_angle = -clamp(velocity_ref.x * 0.002, -0.9, 0.9) - clamp(velocity_ref.y * 0.001, -0.4, 0.4)
	cape_angle = lerp(cape_angle, cape_target_angle, 12.0 * delta)
	
	queue_redraw()

func update_visual_state(vel: Vector2, is_on_floor: bool, is_charging: bool, is_ground_pound: bool, charge_ratio: float) -> void:
	velocity_ref = vel
	charge_progress = charge_ratio
	
	if abs(vel.x) > 10.0:
		look_direction = Vector2(sign(vel.x), clamp(vel.y * 0.002, -0.6, 0.6)).normalized()
	
	if is_charging:
		expression = ExpressionState.CHARGING
	elif is_ground_pound:
		expression = ExpressionState.GROUND_POUNDING
	elif vel.y < -350.0:
		expression = ExpressionState.BOUNCING_HIGH
	elif vel.y > 450.0 and not is_on_floor:
		expression = ExpressionState.FALLING_SCARED
	else:
		expression = ExpressionState.NORMAL

func _draw() -> void:
	# 1. Soft Contact / Drop Shadow
	draw_circle(Vector2(0, 32), 26, Color(0.15, 0.1, 0.2, 0.22))
	
	# 2. Billowing Royal Cape
	_draw_cape()
	
	# 3. Squishy Round Body (Pill / Inflatable cushion)
	_draw_body()
	
	# 4. Golden Wobbling Crown
	_draw_crown()
	
	# 5. Expressive Snipperclips Eyes
	_draw_eyes()
	
	# 6. Reactive Mouth & Cheeks
	_draw_mouth_and_cheeks()

func _draw_cape() -> void:
	var cape_pts = PackedVector2Array()
	var cape_w = 20.0
	var cape_len = 36.0
	var offset_x = -sign(look_direction.x) * 12.0
	if abs(look_direction.x) < 0.2:
		offset_x = -10.0
		
	var origin = Vector2(offset_x, 2)
	var tip1 = origin + Vector2(-cape_w * 0.8, cape_len).rotated(cape_angle)
	var tip2 = origin + Vector2(cape_w * 0.8, cape_len * 0.9).rotated(cape_angle)
	
	cape_pts.append(origin + Vector2(-cape_w * 0.5, 0))
	cape_pts.append(tip1)
	cape_pts.append(tip1.lerp(tip2, 0.5) + Vector2(0, 6).rotated(cape_angle))
	cape_pts.append(tip2)
	cape_pts.append(origin + Vector2(cape_w * 0.5, 0))
	
	draw_colored_polygon(cape_pts, cape_color)
	draw_polyline(cape_pts, Color(0.45, 0.08, 0.14, 1.0), 2.0)

func _draw_body() -> void:
	var radius = 28.0
	var center = Vector2(0, 0)
	
	# Base body with outline
	draw_circle(center, radius + 2.0, Color(0.24, 0.12, 0.18, 1.0))
	draw_circle(center, radius, body_color)
	
	# Bottom shadow curve inside vinyl body
	var shadow_pts = PackedVector2Array()
	for i in range(16):
		var ang = PI * float(i) / 15.0
		shadow_pts.append(center + Vector2(cos(ang) * (radius - 1), sin(ang) * (radius - 1)))
	shadow_pts.append(center + Vector2(0, radius - 6))
	# Subtle bottom shadow
	draw_arc(center, radius - 4.0, 0.2, PI - 0.2, 16, body_shadow_color, 4.0)
	
	# Inflatable Glossy Specular Highlight (The Snipperclips glossy cushion look!)
	var shine_pos = Vector2(-radius * 0.35, -radius * 0.35)
	draw_ellipse_custom(shine_pos, 10.0, 6.0, -0.4, Color(1.0, 1.0, 1.0, 0.55))
	draw_circle(shine_pos + Vector2(-4, -4), 2.5, Color(1.0, 1.0, 1.0, 0.8))

func _draw_crown() -> void:
	var tilt = -clamp(velocity_ref.x * 0.001, -0.25, 0.25)
	var crown_base = Vector2(0, -26)
	
	var pts = PackedVector2Array([
		Vector2(-14, 0).rotated(tilt) + crown_base,
		Vector2(-16, -15).rotated(tilt) + crown_base,
		Vector2(-6, -8).rotated(tilt) + crown_base,
		Vector2(0, -18).rotated(tilt) + crown_base,
		Vector2(6, -8).rotated(tilt) + crown_base,
		Vector2(16, -15).rotated(tilt) + crown_base,
		Vector2(14, 0).rotated(tilt) + crown_base,
	])
	
	# Outline
	draw_colored_polygon(pts, crown_gold)
	pts.append(pts[0])
	draw_polyline(pts, crown_outline, 2.2)
	
	# Ruby jewels on crown tips
	draw_circle(Vector2(0, -17).rotated(tilt) + crown_base, 2.5, Color(0.95, 0.2, 0.3, 1.0))
	draw_circle(Vector2(-15, -14).rotated(tilt) + crown_base, 2.0, Color(0.2, 0.85, 0.9, 1.0))
	draw_circle(Vector2(15, -14).rotated(tilt) + crown_base, 2.0, Color(0.2, 0.85, 0.9, 1.0))

func _draw_eyes() -> void:
	var eye_spacing = 9.0
	var eye_y = -3.0
	var left_eye_center = Vector2(-eye_spacing, eye_y)
	var right_eye_center = Vector2(eye_spacing, eye_y)
	
	if expression == ExpressionState.BOUNCING_HIGH:
		# Happy inverted arc eyes (^_^)
		draw_arc(left_eye_center, 6.5, PI + 0.3, 2.0 * PI - 0.3, 12, crown_outline, 2.8)
		draw_arc(right_eye_center, 6.5, PI + 0.3, 2.0 * PI - 0.3, 12, crown_outline, 2.8)
		return
	
	if is_blinking:
		# Blink slits
		draw_line(left_eye_center + Vector2(-6, 0), left_eye_center + Vector2(6, 0), crown_outline, 2.5)
		draw_line(right_eye_center + Vector2(-6, 0), right_eye_center + Vector2(6, 0), crown_outline, 2.5)
		return
	
	var eye_rx = 7.0
	var eye_ry = 9.0
	
	# Eye deformation based on expression
	if expression == ExpressionState.FALLING_SCARED:
		eye_rx = 9.0
		eye_ry = 11.5 # Big shocked eyes
	elif expression == ExpressionState.CHARGING:
		eye_rx = 7.5
		eye_ry = 5.5 # Squinting eyes (>_<)
	
	# Eye whites
	draw_ellipse_custom(left_eye_center, eye_rx, eye_ry, 0.0, eye_white)
	draw_ellipse_outline(left_eye_center, eye_rx, eye_ry, 0.0, crown_outline, 2.0)
	
	draw_ellipse_custom(right_eye_center, eye_rx, eye_ry, 0.0, eye_white)
	draw_ellipse_outline(right_eye_center, eye_rx, eye_ry, 0.0, crown_outline, 2.0)
	
	# Pupils tracking movement
	var pupil_shift = look_direction * 2.8
	if expression == ExpressionState.FALLING_SCARED:
		pupil_shift = Vector2(0, 3.5) # Looking down at impending drop
	elif expression == ExpressionState.CHARGING:
		pupil_shift = Vector2(0, 1.5)
		
	var pupil_radius = 4.0
	if expression == ExpressionState.FALLING_SCARED:
		pupil_radius = 2.8 # Pinprick scared pupils!
	
	# Left pupil & catchlight
	draw_circle(left_eye_center + pupil_shift, pupil_radius, eye_pupil)
	draw_circle(left_eye_center + pupil_shift + Vector2(1.2, -1.2), pupil_radius * 0.4, eye_white)
	
	# Right pupil & catchlight
	draw_circle(right_eye_center + pupil_shift, pupil_radius, eye_pupil)
	draw_circle(right_eye_center + pupil_shift + Vector2(1.2, -1.2), pupil_radius * 0.4, eye_white)

func _draw_mouth_and_cheeks() -> void:
	# Rosy cute blushing cheeks
	draw_ellipse_custom(Vector2(-18, 5), 4.5, 3.0, 0.0, blush_color)
	draw_ellipse_custom(Vector2(18, 5), 4.5, 3.0, 0.0, blush_color)
	
	var mouth_center = Vector2(0, 9)
	
	match expression:
		ExpressionState.NORMAL:
			# Gentle happy smile
			draw_arc(mouth_center, 6.0, 0.25, PI - 0.25, 12, crown_outline, 2.2)
		
		ExpressionState.BOUNCING_HIGH:
			# Big open joyful mouth :D
			var mouth_pts = PackedVector2Array()
			mouth_pts.append(Vector2(-7, 6))
			mouth_pts.append(Vector2(7, 6))
			mouth_pts.append(Vector2(5, 15))
			mouth_pts.append(Vector2(0, 17))
			mouth_pts.append(Vector2(-5, 15))
			draw_colored_polygon(mouth_pts, crown_outline)
			# Cute pink tongue
			draw_circle(Vector2(0, 14), 4.0, Color(1.0, 0.4, 0.55, 1.0))
		
		ExpressionState.FALLING_SCARED:
			# Surprised/scared "O" mouth
			draw_ellipse_custom(mouth_center + Vector2(0, 2), 4.0, 6.0, 0.0, crown_outline)
		
		ExpressionState.CHARGING:
			# Gritted teeth determined mouth
			draw_line(mouth_center + Vector2(-6, 0), mouth_center + Vector2(6, 0), crown_outline, 2.5)
			draw_line(mouth_center + Vector2(-3, -2), mouth_center + Vector2(-3, 2), crown_outline, 1.8)
			draw_line(mouth_center + Vector2(3, -2), mouth_center + Vector2(3, 2), crown_outline, 1.8)
		
		ExpressionState.GROUND_POUNDING:
			# Fierce downward grimace
			draw_arc(mouth_center + Vector2(0, 6), 6.5, PI + 0.3, 2.0 * PI - 0.3, 12, crown_outline, 2.5)

# Helper for drawing rotated ellipses
func draw_ellipse_custom(pos: Vector2, rx: float, ry: float, rot: float, col: Color) -> void:
	var pts = PackedVector2Array()
	var segments = 16
	for i in range(segments):
		var a = (float(i) / float(segments)) * 2.0 * PI
		var pt = Vector2(cos(a) * rx, sin(a) * ry).rotated(rot) + pos
		pts.append(pt)
	draw_colored_polygon(pts, col)

func draw_ellipse_outline(pos: Vector2, rx: float, ry: float, rot: float, col: Color, width: float) -> void:
	var pts = PackedVector2Array()
	var segments = 16
	for i in range(segments + 1):
		var a = (float(i % segments) / float(segments)) * 2.0 * PI
		var pt = Vector2(cos(a) * rx, sin(a) * ry).rotated(rot) + pos
		pts.append(pt)
	draw_polyline(pts, col, width)
