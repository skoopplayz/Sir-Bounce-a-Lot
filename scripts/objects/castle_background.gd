extends Node2D
class_name CastleBackground

# Procedural Papercraft & Inflatable Backdrop for Sir Bounce a Lot
# Draws soft pastel sky, distant inflatable castle towers, and cute smiling drifting clouds.

@export var sky_top_color: Color = Color(0.92, 0.96, 0.99, 1.0)
@export var sky_bottom_color: Color = Color(1.0, 0.95, 0.92, 1.0)

var cloud_offset: float = 0.0

func _ready() -> void:
	z_index = -10
	queue_redraw()

func _process(delta: float) -> void:
	cloud_offset += delta * 15.0
	queue_redraw()

func _draw() -> void:
	var vp_size = Vector2(3800, 2400)
	var origin = Vector2(-800, -800)
	
	# 1. Sky Gradient (Approximated with horizontal color strips)
	var strips = 16
	var strip_h = vp_size.y / float(strips)
	for i in range(strips):
		var t = float(i) / float(strips)
		var col = sky_top_color.lerp(sky_bottom_color, t)
		draw_rect(Rect2(origin.x, origin.y + float(i) * strip_h, vp_size.x, strip_h + 1.0), col, true)
	
	# 2. Distant Inflatable Castle Towers (Silhouette in pastel lavender/cyan)
	var tower_col = Color(0.85, 0.88, 0.96, 0.6)
	var tower_trim = Color(0.78, 0.82, 0.92, 0.7)
	
	for i in range(7):
		var tx = origin.x + 200.0 + float(i) * 520.0
		var ty = 400.0
		var tw = 140.0
		var th = 450.0
		draw_rect(Rect2(tx, ty, tw, th), tower_col, true)
		# Tower cone roof
		var roof_pts = PackedVector2Array([
			Vector2(tx - 15, ty),
			Vector2(tx + tw * 0.5, ty - 120),
			Vector2(tx + tw + 15, ty)
		])
		draw_colored_polygon(roof_pts, tower_trim)
		# Little flag on roof
		draw_line(Vector2(tx + tw * 0.5, ty - 120), Vector2(tx + tw * 0.5, ty - 150), tower_trim, 2.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(tx + tw * 0.5, ty - 150),
			Vector2(tx + tw * 0.5 + 20, ty - 140),
			Vector2(tx + tw * 0.5, ty - 130)
		]), Color(0.96, 0.65, 0.75, 0.7))

	# 3. Drifting Papercraft Clouds with cute faces
	_draw_smiling_cloud(Vector2(fmod(cloud_offset * 0.8 + 200.0, 3200.0) - 400.0, -120.0), 70.0)
	_draw_smiling_cloud(Vector2(fmod(cloud_offset * 0.5 + 900.0, 3200.0) - 400.0, 50.0), 90.0)
	_draw_smiling_cloud(Vector2(fmod(cloud_offset * 0.6 + 1800.0, 3200.0) - 400.0, -60.0), 80.0)
	_draw_smiling_cloud(Vector2(fmod(cloud_offset * 0.7 + 2600.0, 3200.0) - 400.0, 110.0), 65.0)

func _draw_smiling_cloud(pos: Vector2, rad: float) -> void:
	var col = Color(1.0, 1.0, 1.0, 0.88)
	var outline = Color(0.75, 0.82, 0.9, 0.6)
	
	# Cloud puff circles
	draw_circle(pos + Vector2(-rad * 0.6, 0), rad * 0.65, col)
	draw_circle(pos + Vector2(rad * 0.6, 0), rad * 0.65, col)
	draw_circle(pos + Vector2(0, -rad * 0.35), rad * 0.75, col)
	draw_circle(pos, rad * 0.7, col)
	
	# Cute little Snipperclips sleeping/happy smile on the cloud
	var eye_y = pos.y - 4.0
	draw_arc(Vector2(pos.x - 12, eye_y), 4.0, PI + 0.2, 2.0 * PI - 0.2, 8, Color(0.35, 0.4, 0.5, 0.6), 1.8)
	draw_arc(Vector2(pos.x + 12, eye_y), 4.0, PI + 0.2, 2.0 * PI - 0.2, 8, Color(0.35, 0.4, 0.5, 0.6), 1.8)
	draw_arc(Vector2(pos.x, eye_y + 8), 4.5, 0.2, PI - 0.2, 8, Color(0.35, 0.4, 0.5, 0.6), 1.8)
	# Rosy cloud cheeks
	draw_circle(Vector2(pos.x - 20, eye_y + 4), 3.0, Color(1.0, 0.6, 0.7, 0.4))
	draw_circle(Vector2(pos.x + 20, eye_y + 4), 3.0, Color(1.0, 0.6, 0.7, 0.4))
