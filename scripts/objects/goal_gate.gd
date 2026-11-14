extends Area2D
class_name GoalGate

# Castle Inflatable Exit Gateway
# When Prince reaches the gate, cuts the victory ribbon and triggers confetti fanfare!

var is_activated: bool = false
var ribbon_cut: bool = false
var flag_wave: float = 0.0

@onready var confetti_particles: CPUParticles2D = $ConfettiParticles

# Colors
var arch_color: Color = Color(0.96, 0.42, 0.52, 1.0) # Inflatable castle pink
var arch_trim: Color = Color(1.0, 0.88, 0.25, 1.0)  # Gold trim
var flag_color: Color = Color(0.25, 0.82, 0.88, 1.0) # Sky cyan
var ribbon_color: Color = Color(1.0, 0.2, 0.35, 1.0)
var outline_col: Color = Color(0.2, 0.15, 0.22, 1.0)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	flag_wave += delta * 6.0
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
	if body is Prince:
		is_activated = true
		ribbon_cut = true
		if confetti_particles:
			confetti_particles.restart()
			confetti_particles.emitting = true
		
		# Slight bounce freeze
		body.velocity = Vector2(0, -320)
		body.apply_squash_stretch(0.7, 1.4)
		GameManager.complete_level()

func _draw() -> void:
	# 1. Left & Right Inflatable Castle Pillars
	var pillar_w = 26.0
	var pillar_h = 130.0
	var span = 90.0
	
	# Left Pillar
	_draw_pillar(Vector2(-span * 0.5, 0), pillar_w, pillar_h)
	# Right Pillar
	_draw_pillar(Vector2(span * 0.5, 0), pillar_w, pillar_h)
	
	# 2. Top Inflatable Arch
	var arch_rect = Rect2(-span * 0.5 - pillar_w * 0.5, -pillar_h - 18, span + pillar_w, 22)
	draw_rect(arch_rect, outline_col)
	draw_rect(Rect2(arch_rect.position + Vector2(2, 2), arch_rect.size - Vector2(4, 4)), arch_trim)
	
	# Castle Crenellations (teeth) on top
	for i in range(4):
		var tooth_x = -span * 0.5 + float(i) * 32.0 - 10.0
		var tooth_rect = Rect2(tooth_x, -pillar_h - 32, 18, 14)
		draw_rect(tooth_rect, outline_col)
		draw_rect(Rect2(tooth_rect.position + Vector2(2, 2), tooth_rect.size - Vector2(4, 4)), arch_color)
		
	# 3. Waving Royal Flags on top
	_draw_flag(Vector2(-span * 0.5 - 4, -pillar_h - 32), -1.0)
	_draw_flag(Vector2(span * 0.5 + 4, -pillar_h - 32), 1.0)
	
	# 4. Victory Ribbon
	if not ribbon_cut:
		var ribbon_y = -35.0
		var pts = PackedVector2Array([
			Vector2(-span * 0.5 + 10, ribbon_y),
			Vector2(0, ribbon_y + 8.0),
			Vector2(span * 0.5 - 10, ribbon_y)
		])
		draw_polyline(pts, outline_col, 8.0)
		draw_polyline(pts, ribbon_color, 5.0)
		# Bow in the middle
		draw_circle(Vector2(0, ribbon_y + 8.0), 6.0, arch_trim)
	else:
		# Cut ribbon fluttering
		draw_line(Vector2(-span * 0.5 + 10, -35), Vector2(-15, -20), ribbon_color, 4.0)
		draw_line(Vector2(span * 0.5 - 10, -35), Vector2(15, -20), ribbon_color, 4.0)

func _draw_pillar(pos: Vector2, w: float, h: float) -> void:
	var rect = Rect2(pos.x - w * 0.5, pos.y - h, w, h)
	draw_rect(rect, outline_col)
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), arch_color)
	# Inflatable stitch seams
	for i in range(4):
		var y_pos = pos.y - h + float(i) * 30.0 + 15.0
		draw_line(Vector2(pos.x - w * 0.4, y_pos), Vector2(pos.x + w * 0.4, y_pos), arch_trim, 2.0)

func _draw_flag(pos: Vector2, dir: float) -> void:
	# Flag pole
	draw_line(pos, pos + Vector2(0, -28), outline_col, 2.5)
	# Pennant flag
	var wave = sin(flag_wave) * 4.0
	var pts = PackedVector2Array([
		pos + Vector2(0, -28),
		pos + Vector2(22 * dir, -20 + wave),
		pos + Vector2(0, -12)
	])
	draw_colored_polygon(pts, flag_color)
	draw_polyline(pts, outline_col, 1.8)
