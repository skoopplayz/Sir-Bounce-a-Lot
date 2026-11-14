extends RigidBody2D
class_name FireBubble

# Bouncy Fire Bubble shot by Ignis the Dragon
# Translucent, bouncy, pops after several bounces or when ground-pounded!

var bounces_left: int = 4
var life_time: float = 6.0
var bubble_radius: float = 16.0
var wobble_timer: float = 0.0

@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	contact_monitor = true
	max_contacts_reported = 4
	queue_redraw()

func _physics_process(delta: float) -> void:
	wobble_timer += delta * 12.0
	life_time -= delta
	if life_time <= 0.0:
		pop()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is Prince:
		if body.is_ground_pounding:
			# Player bounced directly on the bubble -> popped it safely and bounced high!
			body.bounce_off_surface(Vector2(0, -620))
			pop()
			return
		else:
			body.take_damage(global_position)
			pop()
			return
			
	bounces_left -= 1
	SoundManager.play_pop()
	if bounces_left <= 0:
		pop()

func on_ground_pounded(prince: Prince) -> void:
	prince.bounce_off_surface(Vector2(0, -680))
	pop()

func pop() -> void:
	SoundManager.play_pop()
	if particles:
		particles.restart()
		particles.emitting = true
	queue_free()

func _draw() -> void:
	var r = bubble_radius + sin(wobble_timer) * 1.5
	
	# Translucent fiery orange/red bubble
	draw_circle(Vector2.ZERO, r, Color(1.0, 0.45, 0.15, 0.65))
	draw_arc(Vector2.ZERO, r, 0.0, 2.0 * PI, 18, Color(1.0, 0.25, 0.1, 0.9), 2.0)
	
	# Inner flame spark
	draw_circle(Vector2(0, 1), r * 0.45, Color(1.0, 0.88, 0.2, 0.8))
	
	# Bubble gloss highlight
	draw_circle(Vector2(-r * 0.35, -r * 0.35), r * 0.22, Color(1.0, 1.0, 1.0, 0.7))
