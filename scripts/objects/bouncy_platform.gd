@tool
extends StaticBody2D
class_name BouncyPlatform

# Modular Inflatable Castle Platform
# Features Snipperclips paper/vinyl aesthetic with rounded corners,
# stitched seam dots, and optional soft bouncy physics.

@export var size: Vector2 = Vector2(200, 48):
	set(val):
		size = val
		_update_shape()
		queue_redraw()

@export var platform_color: Color = Color(0.96, 0.42, 0.55, 1.0):
	set(val):
		platform_color = val
		queue_redraw()

@export var is_bouncy: bool = false
@export var bounce_strength: float = 600.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_update_shape()
	queue_redraw()

func _update_shape() -> void:
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		var rect = RectangleShape2D.new()
		rect.size = size
		collision_shape.shape = rect

func _draw() -> void:
	var hw = size.x * 0.5
	var hh = size.y * 0.5
	var rect = Rect2(-hw, -hh, size.x, size.y)
	var outline_col = Color(0.2, 0.15, 0.22, 1.0)
	var seam_col = Color(1.0, 0.88, 0.35, 0.85)
	
	# Drop shadow
	draw_rect(Rect2(-hw + 3, -hh + 6, size.x, size.y), Color(0.12, 0.08, 0.18, 0.18), true)
	
	# Main Inflatable Body
	draw_rect(rect, outline_col, true)
	var inner_rect = Rect2(-hw + 2.5, -hh + 2.5, size.x - 5.0, size.y - 5.0)
	draw_rect(inner_rect, platform_color, true)
	
	# Glossy top highlight
	if size.y > 16.0:
		var highlight_rect = Rect2(-hw + 6, -hh + 5, size.x - 12.0, 4.0)
		draw_rect(highlight_rect, Color(1.0, 1.0, 1.0, 0.45), true)
	
	# Stitched Seam Dots along the edge
	var dot_spacing = 20.0
	var count_x = int((size.x - 20) / dot_spacing)
	for i in range(count_x):
		var dx = -hw + 14.0 + float(i) * dot_spacing
		draw_circle(Vector2(dx, -hh + 10.0), 1.8, seam_col)
		if size.y > 28.0:
			draw_circle(Vector2(dx, hh - 10.0), 1.8, seam_col)

# If is_bouncy, bounce player on top contact
func _on_top_bounce_trigger(body: Node2D) -> void:
	if is_bouncy and body is Prince:
		body.bounce_off_surface(Vector2.UP * bounce_strength, false)
