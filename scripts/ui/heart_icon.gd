extends Control

# Procedural Bouncing Heart Icon for HUD

var time_offset: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(28, 28)
	time_offset = randf() * 2.0
	queue_redraw()

func _process(delta: float) -> void:
	time_offset += delta * 4.0
	var scale_factor = 1.0 + sin(time_offset) * 0.08
	scale = Vector2(scale_factor, scale_factor)
	queue_redraw()

func _draw() -> void:
	var pts = PackedVector2Array()
	var center = Vector2(14, 14)
	# Heart formula
	var steps = 24
	for i in range(steps):
		var t = (float(i) / float(steps)) * 2.0 * PI
		var x = 16.0 * pow(sin(t), 3)
		var y = -(13.0 * cos(t) - 5.0 * cos(2.0*t) - 2.0 * cos(3.0*t) - cos(4.0*t))
		pts.append(center + Vector2(x * 0.7, y * 0.7))
	
	draw_colored_polygon(pts, Color(0.96, 0.22, 0.38, 1.0))
	draw_polyline(pts, Color(0.2, 0.12, 0.18, 1.0), 2.0)
