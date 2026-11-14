extends Node2D

# Snipperclips-style Procedural Visual Rig for Ignis the Inflatable Dragon
# Features:
# - Flapping inflatable wings
# - Rounded vinyl cushion body with stitching seams
# - Expressive googly dragon eyes with spinning dizzy spirals when hit
# - Bouncy soft-body squash/stretch belly
# - Curved playful horns and tail

@onready var boss: CharacterBody2D = get_parent()

# Colors
var dragon_purple: Color = Color(0.62, 0.32, 0.88, 1.0) # Inflatable rich purple
var dragon_belly_gold: Color = Color(1.0, 0.82, 0.28, 1.0)
var dragon_horns: Color = Color(1.0, 0.94, 0.55, 1.0)
var wing_membrane: Color = Color(0.85, 0.45, 0.95, 0.85)
var outline_col: Color = Color(0.2, 0.12, 0.25, 1.0)
var eye_white: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not boss:
		return
		
	var flap = sin(boss.wing_flap_timer)
	var squash = boss.belly_squash
	
	# If enraged (low hp), shift color towards fiery crimson!
	var current_body_color = dragon_purple
	if boss.current_hp <= 2:
		current_body_color = Color(0.92, 0.28, 0.32, 1.0) # Fiery rage mode!
		
	# 1. Tail with inflatable ball
	_draw_tail()
	
	# 2. Inflatable Flapping Wings (Behind body)
	_draw_wings(flap)
	
	# 3. Dragon Main Body (Squishy rounded shape)
	_draw_main_body(squash, current_body_color)
	
	# 4. Inflatable Bouncy Belly (Vulnerable bounce pad)
	_draw_belly(squash)
	
	# 5. Playful Curved Horns & Back Spines
	_draw_horns()
	
	# 6. Big Snipperclips Googly Dragon Eyes
	_draw_eyes()
	
	# 7. Cute Nostrils / Mouth
	_draw_snout()

func _draw_tail() -> void:
	var pts = PackedVector2Array()
	var base = Vector2(-45, 20)
	pts.append(base)
	pts.append(base + Vector2(-30, 15))
	pts.append(base + Vector2(-60, 5))
	pts.append(base + Vector2(-80, -15))
	draw_polyline(pts, outline_col, 14.0)
	draw_polyline(pts, dragon_purple, 10.0)
	# Tail ball bumper
	draw_circle(base + Vector2(-80, -15), 14.0, outline_col)
	draw_circle(base + Vector2(-80, -15), 12.0, dragon_belly_gold)

func _draw_wings(flap: float) -> void:
	var wing_span = 55.0
	var wing_angle = flap * 0.45
	
	# Left Wing
	var l_root = Vector2(-25, -25)
	var l_pts = PackedVector2Array([
		l_root,
		l_root + Vector2(-wing_span, -30).rotated(wing_angle),
		l_root + Vector2(-wing_span * 0.7, 10).rotated(wing_angle),
		l_root + Vector2(-20, 10)
	])
	draw_colored_polygon(l_pts, wing_membrane)
	l_pts.append(l_pts[0])
	draw_polyline(l_pts, outline_col, 3.0)
	
	# Right Wing
	var r_root = Vector2(25, -25)
	var r_pts = PackedVector2Array([
		r_root,
		r_root + Vector2(wing_span, -30).rotated(-wing_angle),
		r_root + Vector2(wing_span * 0.7, 10).rotated(-wing_angle),
		r_root + Vector2(20, 10)
	])
	draw_colored_polygon(r_pts, wing_membrane)
	r_pts.append(r_pts[0])
	draw_polyline(r_pts, outline_col, 3.0)

func _draw_main_body(squash: Vector2, col: Color) -> void:
	var rx = 65.0 * squash.x
	var ry = 58.0 * squash.y
	_draw_ellipse(Vector2.ZERO, rx + 3.0, ry + 3.0, 0.0, outline_col)
	_draw_ellipse(Vector2.ZERO, rx, ry, 0.0, col)
	
	# Inflatable vinyl gloss highlight
	_draw_ellipse(Vector2(-rx * 0.4, -ry * 0.4), 18.0, 10.0, -0.4, Color(1.0, 1.0, 1.0, 0.4))

func _draw_belly(squash: Vector2) -> void:
	var belly_center = Vector2(0, 12)
	var rx = 44.0 * squash.x
	var ry = 36.0 * squash.y
	_draw_ellipse(belly_center, rx + 2.0, ry + 2.0, 0.0, outline_col)
	_draw_ellipse(belly_center, rx, ry, 0.0, dragon_belly_gold)
	
	# Belly inflatable stripe seams
	draw_line(belly_center + Vector2(-rx * 0.7, -4), belly_center + Vector2(rx * 0.7, -4), Color(0.85, 0.65, 0.15, 0.9), 2.5)
	draw_line(belly_center + Vector2(-rx * 0.8, 8), belly_center + Vector2(rx * 0.8, 8), Color(0.85, 0.65, 0.15, 0.9), 2.5)
	draw_line(belly_center + Vector2(-rx * 0.6, 20), belly_center + Vector2(rx * 0.6, 20), Color(0.85, 0.65, 0.15, 0.9), 2.5)

func _draw_horns() -> void:
	# Left horn
	var l_pts = PackedVector2Array([Vector2(-24, -45), Vector2(-42, -75), Vector2(-15, -52)])
	draw_colored_polygon(l_pts, dragon_horns)
	l_pts.append(l_pts[0])
	draw_polyline(l_pts, outline_col, 2.5)
	
	# Right horn
	var r_pts = PackedVector2Array([Vector2(24, -45), Vector2(42, -75), Vector2(15, -52)])
	draw_colored_polygon(r_pts, dragon_horns)
	r_pts.append(r_pts[0])
	draw_polyline(r_pts, outline_col, 2.5)

func _draw_eyes() -> void:
	var eye_y = -18.0
	var left_eye = Vector2(-20, eye_y)
	var right_eye = Vector2(20, eye_y)
	
	_draw_ellipse(left_eye, 14.0, 16.0, 0.0, eye_white)
	_draw_ellipse_outline(left_eye, 14.0, 16.0, 0.0, outline_col, 2.5)
	
	_draw_ellipse(right_eye, 14.0, 16.0, 0.0, eye_white)
	_draw_ellipse_outline(right_eye, 14.0, 16.0, 0.0, outline_col, 2.5)
	
	if boss.eyes_dizzy:
		# Dizzy spiral eyes when stunned! (@_@)
		_draw_spiral(left_eye, 8.0)
		_draw_spiral(right_eye, 8.0)
	else:
		# Cute vertical dragon slit pupils
		_draw_ellipse(left_eye, 4.5, 9.0, 0.0, outline_col)
		draw_circle(left_eye + Vector2(2, -3), 2.0, Color.WHITE)
		
		_draw_ellipse(right_eye, 4.5, 9.0, 0.0, outline_col)
		draw_circle(right_eye + Vector2(2, -3), 2.0, Color.WHITE)

func _draw_snout() -> void:
	# Cute dragon nostrils
	draw_circle(Vector2(-7, 3), 2.5, outline_col)
	draw_circle(Vector2(7, 3), 2.5, outline_col)

func _draw_spiral(pos: Vector2, radius: float) -> void:
	var pts = PackedVector2Array()
	var steps = 24
	for i in range(steps):
		var t = float(i) / float(steps)
		var angle = t * 4.0 * PI
		var r = t * radius
		pts.append(pos + Vector2(cos(angle) * r, sin(angle) * r))
	draw_polyline(pts, outline_col, 2.0)

func _draw_ellipse(pos: Vector2, rx: float, ry: float, rot: float, col: Color) -> void:
	var pts = PackedVector2Array()
	var segs = 18
	for i in range(segs):
		var a = (float(i) / float(segs)) * 2.0 * PI
		pts.append(Vector2(cos(a) * rx, sin(a) * ry).rotated(rot) + pos)
	draw_colored_polygon(pts, col)

func _draw_ellipse_outline(pos: Vector2, rx: float, ry: float, rot: float, col: Color, width: float) -> void:
	var pts = PackedVector2Array()
	var segs = 18
	for i in range(segs + 1):
		var a = (float(i % segs) / float(segs)) * 2.0 * PI
		pts.append(Vector2(cos(a) * rx, sin(a) * ry).rotated(rot) + pos)
	draw_polyline(pts, col, width)
