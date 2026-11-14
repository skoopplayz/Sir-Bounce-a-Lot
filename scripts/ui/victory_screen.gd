extends Control

# Victory Celebration Screen for Sir Bounce a Lot
# Grand confetti fireworks, stats recap, and happy dancing prince & princess!

@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var btn_play_again: Button = $VBoxContainer/BtnPlayAgain
@onready var btn_menu: Button = $VBoxContainer/BtnMenu
@onready var confetti_particles: CPUParticles2D = $Confetti

var dance_timer: float = 0.0

func _ready() -> void:
	btn_play_again.pressed.connect(_on_play_again_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)
	
	stats_label.text = "Golden Rings Gathered: %d\nLives Remaining: %d / %d" % [GameManager.rings, GameManager.lives, GameManager.MAX_LIVES]
	if confetti_particles:
		confetti_particles.emitting = true
	SoundManager.play_victory()

func _process(delta: float) -> void:
	dance_timer += delta * 6.0
	$Dancers/PrinceDance.position.y = 480.0 + sin(dance_timer) * 16.0
	$Dancers/PrincessDance.position.y = 480.0 + sin(dance_timer + 0.8) * 16.0

func _on_play_again_pressed() -> void:
	SoundManager.play_super_bounce()
	GameManager.reset_game()
	GameManager.load_level(1)

func _on_menu_pressed() -> void:
	SoundManager.play_jump()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
