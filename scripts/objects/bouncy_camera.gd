extends Camera2D
class_name BouncyCamera

# Dynamic Camera with smooth follow, spring zoom, and screen shake

@export var target_node: NodePath
var target: Node2D

var shake_intensity: float = 0.0
var shake_duration: float = 0.0

@export var min_zoom: float = 0.85
@export var max_zoom: float = 1.15
var target_zoom: float = 1.0

func _ready() -> void:
	GameManager.camera_shake_requested.connect(_on_camera_shake_requested)
	if target_node:
		target = get_node_or_null(target_node)
	elif get_tree().has_group("player"):
		target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not target:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]
			
	if target:
		# Smooth follow target position
		var target_pos = target.global_position + Vector2(0, -40)
		global_position = global_position.lerp(target_pos, 8.0 * delta)
		
		# Dynamic zoom based on vertical velocity
		if target is CharacterBody2D:
			var speed_y = abs(target.velocity.y)
			if speed_y > 400.0:
				target_zoom = lerp(1.0, min_zoom, clamp((speed_y - 400.0) / 800.0, 0.0, 1.0))
			else:
				target_zoom = 1.0
		
		zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 5.0 * delta)
	
	# Screen Shake
	if shake_duration > 0.0:
		shake_duration -= delta
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		if shake_duration <= 0.0:
			offset = Vector2.ZERO

func _on_camera_shake_requested(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
