extends Node

# Global Game Manager for Sir Bounce a Lot
# Handles state, transitions, scoring, lives, checkpoints, and camera shake signals.

signal rings_changed(new_count: int)
signal lives_changed(new_lives: int)
signal level_completed(level_index: int)
signal checkpoint_activated(pos: Vector2)
signal super_bounce_cooldown_changed(current: float, max_val: float)
signal camera_shake_requested(intensity: float, duration: float)

var current_level: int = 1
var rings: int = 0
var lives: int = 3
const MAX_LIVES: int = 3

# Checkpoint system
var current_checkpoint: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false
var default_spawn_position: Vector2 = Vector2(160, 480)

var level_paths: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4_boss.tscn"
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset_game() -> void:
	current_level = 1
	rings = 0
	lives = MAX_LIVES
	has_checkpoint = false
	current_checkpoint = Vector2.ZERO
	emit_signal("rings_changed", rings)
	emit_signal("lives_changed", lives)

func add_ring(amount: int = 1) -> void:
	rings += amount
	emit_signal("rings_changed", rings)
	SoundManager.play_coin()

func register_checkpoint(pos: Vector2) -> void:
	current_checkpoint = pos
	has_checkpoint = true
	SoundManager.play_checkpoint()
	emit_signal("checkpoint_activated", pos)

func get_respawn_position() -> Vector2:
	if has_checkpoint:
		return current_checkpoint
	return default_spawn_position

func handle_player_fall_or_death(player: Node2D) -> void:
	lives -= 1
	emit_signal("lives_changed", lives)
	SoundManager.play_hurt()
	request_camera_shake(14.0, 0.45)
	
	if lives <= 0:
		# Game over restart to level 1
		await get_tree().create_timer(1.0).timeout
		reset_game()
		load_level(1)
	else:
		# Respawn at checkpoint!
		await get_tree().create_timer(0.4).timeout
		var target_pos = get_respawn_position()
		if player and is_instance_valid(player) and player.has_method("respawn_at"):
			player.respawn_at(target_pos)

func complete_level() -> void:
	emit_signal("level_completed", current_level)
	SoundManager.play_victory()
	has_checkpoint = false
	current_checkpoint = Vector2.ZERO
	
	if current_level < level_paths.size():
		current_level += 1
		await get_tree().create_timer(1.2).timeout
		load_level(current_level)
	else:
		# Boss beaten! Go to victory scene
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")

func load_level(level_num: int) -> void:
	has_checkpoint = false
	current_checkpoint = Vector2.ZERO
	current_level = clampi(level_num, 1, level_paths.size())
	var path = level_paths[current_level - 1]
	get_tree().change_scene_to_file(path)

func restart_current_level() -> void:
	var path = level_paths[current_level - 1]
	get_tree().change_scene_to_file(path)

func request_camera_shake(intensity: float = 8.0, duration: float = 0.3) -> void:
	emit_signal("camera_shake_requested", intensity, duration)
