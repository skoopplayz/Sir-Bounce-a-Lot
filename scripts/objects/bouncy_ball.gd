extends RigidBody2D
class_name BouncyBall

# Inflatable Physics Beach Ball
# Can be pushed, kicked, launched by seesaw or bounced on.

@export var ball_radius: float = 24.0

var slice_colors: Array[Color] = [
	Color(0.98, 0.35, 0.45, 1.0), # Red/Coral
	Color(1.0, 0.88, 0.25, 1.0),  # Yellow
	Color(0.25, 0.85, 0.88, 1.0), # Cyan
	Color(1.0, 1.0, 1.0, 1.0)     # White
]

func _ready() -> void:
	queue_redraw()

func _physics_process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Drop shadow
	draw_circle(Vector2(0, ball_radius * 0.9), ball_radius * 0.7, Color(0.15, 0.1, 0.2, 0.2))
	
	# Ball slices
	var total_slices = 6
	for i in range(total_slices):
		var a1 = (float(i) / float(total_slices)) * 2.0 * PI
		var a2 = (float(i + 1) / float(total_slices)) * 2.0 * PI
		var col = slice_colors[i % slice_colors.size()]
		
		var pts = PackedVector2Array([Vector2.ZERO])
		var arc_steps = 8
		for s in range(arc_steps + 1):
			var ang = lerp(a1, a2, float(s) / float(arc_steps))
			pts.append(Vector2(cos(ang) * ball_radius, sin(ang) * ball_radius))
		draw_colored_polygon(pts, col)
		
	# Outer border
	draw_arc(Vector2.ZERO, ball_radius, 0.0, 2.0 * PI, 24, Color(0.2, 0.15, 0.22, 1.0), 2.2)
	
	# Center circle
	draw_circle(Vector2.ZERO, ball_radius * 0.22, Color.WHITE)
	draw_arc(Vector2.ZERO, ball_radius * 0.22, 0.0, 2.0 * PI, 12, Color(0.2, 0.15, 0.22, 1.0), 1.8)
	
	# Glossy highlight
	draw_circle(Vector2(-ball_radius * 0.35, -ball_radius * 0.35), ball_radius * 0.2, Color(1.0, 1.0, 1.0, 0.5))
