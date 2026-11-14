extends Area2D
class_name CollectibleRing

# Golden Bouncy Ring Collectible
# Floating golden ring that rewards points and plays musical chime

var time_passed: float = 0.0
var is_collected: bool = false
@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	time_passed = randf() * 10.0
	queue_redraw()

func _process(delta: float) -> void:
	if not is_collected:
		time_passed += delta * 3.5
		position.y += sin(time_passed) * 0.4
		queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body is Prince:
		is_collected = true
		GameManager.add_ring(1)
		if particles:
			particles.restart()
			particles.emitting = true
		
		# Fade and pop out
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
		tween.tween_property(self, "modulate:a", 0.0, 0.15)
		await tween.finished
		queue_free()

func _draw() -> void:
	var stretch_x = abs(cos(time_passed)) * 0.6 + 0.4
	var gold_outer = Color(1.0, 0.85, 0.2, 1.0)
	var gold_inner = Color(1.0, 0.95, 0.5, 1.0)
	var outline = Color(0.25, 0.2, 0.15, 1.0)
	
	# Drop shadow
	draw_ellipse_custom(Vector2(0, 20), 16.0 * stretch_x, 4.0, Color(0.15, 0.1, 0.2, 0.2))
	
	# Outer ring
	draw_ellipse_custom(Vector2.ZERO, 16.0 * stretch_x, 16.0, outline)
	draw_ellipse_custom(Vector2.ZERO, 14.0 * stretch_x, 14.0, gold_outer)
	draw_ellipse_custom(Vector2.ZERO, 9.0 * stretch_x, 9.0, outline)
	draw_ellipse_custom(Vector2.ZERO, 7.5 * stretch_x, 7.5, Color(0.95, 0.96, 0.98, 1.0)) # Transparent inner hole
	
	# Sparkle star
	if fmod(time_passed, 3.0) < 0.6:
		var spark_pos = Vector2(8.0 * stretch_x, -10.0)
		draw_circle(spark_pos, 2.5, Color.WHITE)

func draw_ellipse_custom(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts = PackedVector2Array()
	var segs = 14
	for i in range(segs):
		var a = (float(i) / float(segs)) * 2.0 * PI
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)
