extends Control

# Main Menu for Sir Bounce a Lot
# Features animated bouncy characters, level select, and controls guide

@onready var btn_start: Button = $VBoxContainer/BtnStart
@onready var btn_level_select: Button = $VBoxContainer/BtnLevelSelect
@onready var btn_controls: Button = $VBoxContainer/BtnControls
@onready var level_select_panel: Panel = $LevelSelectPanel
@onready var controls_panel: Panel = $ControlsPanel

var bounce_timer: float = 0.0

func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_level_select.pressed.connect(_on_level_select_pressed)
	btn_controls.pressed.connect(_on_controls_pressed)
	
	# Level buttons
	$LevelSelectPanel/VBox/HBox/BtnL1.pressed.connect(func(): _load_lvl(1))
	$LevelSelectPanel/VBox/HBox/BtnL2.pressed.connect(func(): _load_lvl(2))
	$LevelSelectPanel/VBox/HBox/BtnL3.pressed.connect(func(): _load_lvl(3))
	$LevelSelectPanel/VBox/HBox/BtnL4.pressed.connect(func(): _load_lvl(4))
	$LevelSelectPanel/VBox/BtnCloseLevels.pressed.connect(func(): level_select_panel.visible = false)
	$ControlsPanel/VBox/BtnCloseControls.pressed.connect(func(): controls_panel.visible = false)
	
	level_select_panel.visible = false
	controls_panel.visible = false

func _process(delta: float) -> void:
	bounce_timer += delta * 5.0
	$TitleContainer/Title.position.y = 80.0 + sin(bounce_timer) * 8.0

func _on_start_pressed() -> void:
	SoundManager.play_jump()
	GameManager.reset_game()
	GameManager.load_level(1)

func _on_level_select_pressed() -> void:
	SoundManager.play_pop()
	level_select_panel.visible = not level_select_panel.visible
	controls_panel.visible = false

func _on_controls_pressed() -> void:
	SoundManager.play_pop()
	controls_panel.visible = not controls_panel.visible
	level_select_panel.visible = false

func _load_lvl(lvl: int) -> void:
	SoundManager.play_super_bounce()
	GameManager.reset_game()
	GameManager.load_level(lvl)
