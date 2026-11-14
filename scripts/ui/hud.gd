extends CanvasLayer

# HUD for Sir Bounce a Lot
# Displays cute hearts for lives, golden ring count, level name, and Boss HP bar.

@onready var lives_container: HBoxContainer = $Margin/TopBar/LivesContainer
@onready var rings_label: Label = $Margin/TopBar/RingsContainer/RingsLabel
@onready var level_label: Label = $Margin/TopBar/LevelLabel
@onready var boss_container: VBoxContainer = $Margin/BossContainer
@onready var boss_bar: ProgressBar = $Margin/BossContainer/BossBar
@onready var hint_label: Label = $Margin/BottomBar/HintLabel

var heart_textures: Array[Control] = []

func _ready() -> void:
	GameManager.rings_changed.connect(_on_rings_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.checkpoint_activated.connect(_on_checkpoint_activated)
	
	_update_rings_display(GameManager.rings)
	_update_lives_display(GameManager.lives)
	
	# Check if boss exists in scene
	var boss = get_tree().get_first_node_in_group("boss")
	if boss and boss.has_signal("boss_damaged"):
		boss.boss_damaged.connect(_on_boss_damaged)
		boss_container.visible = true
		boss_bar.max_value = boss.max_hp
		boss_bar.value = boss.current_hp
	else:
		boss_container.visible = false

	# Set level name
	var level_names = [
		"Level 1: The Inflatable Courtyard",
		"Level 2: The Bouncing Chambers & Seesaws",
		"Level 3: The Royal Cloud Spire",
		"Level 4: Final Boss - Ignis the Bouncy Dragon!"
	]
	var idx = GameManager.current_level - 1
	if idx >= 0 and idx < level_names.size():
		level_label.text = level_names[idx]
	else:
		level_label.text = "Sir Bounce a Lot"

func _on_rings_changed(new_count: int) -> void:
	_update_rings_display(new_count)

func _on_lives_changed(new_lives: int) -> void:
	_update_lives_display(new_lives)

func _update_rings_display(count: int) -> void:
	if rings_label:
		rings_label.text = "x %02d" % count

func _update_lives_display(lives_left: int) -> void:
	if not lives_container:
		return
	for i in range(lives_container.get_child_count()):
		var heart = lives_container.get_child(i)
		heart.modulate = Color.WHITE if i < lives_left else Color(0.4, 0.4, 0.4, 0.4)

func _on_boss_damaged(new_hp: int, max_hp: int) -> void:
	if boss_container and boss_bar:
		boss_container.visible = true
		boss_bar.max_value = max_hp
		boss_bar.value = new_hp
		# Flash bar
		var tween = create_tween()
		boss_bar.modulate = Color(1.5, 1.5, 1.5, 1.0)
		tween.tween_property(boss_bar, "modulate", Color.WHITE, 0.25)

func _on_checkpoint_activated(_pos: Vector2) -> void:
	if hint_label:
		var orig_text = hint_label.text
		hint_label.text = "🚩 CHECKPOINT ACTIVATED! Respawn point set! 🚩"
		hint_label.modulate = Color(1.0, 0.88, 0.25, 1.0)
		var tween = create_tween()
		tween.tween_property(hint_label, "scale", Vector2(1.15, 1.15), 0.15)
		tween.tween_property(hint_label, "scale", Vector2.ONE, 0.15)
		await get_tree().create_timer(2.2).timeout
		if hint_label:
			hint_label.text = orig_text
			hint_label.modulate = Color.WHITE
