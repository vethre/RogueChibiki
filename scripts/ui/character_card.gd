extends Control

signal character_clicked(character: CharacterData)

var character_data: CharacterData

@onready var portrait: TextureRect = $Panel/VBoxContainer/PortraitBG/Portrait
@onready var name_label: Label = $Panel/VBoxContainer/NameLabel
@onready var passive_label: Label = $Panel/VBoxContainer/PassiveLabel
@onready var select_hint: Label = $Panel/VBoxContainer/SelectHint
@onready var panel: Panel = $Panel
@onready var lock_overlay: ColorRect = $Panel/LockOverlay
@onready var lock_label: Label = $Panel/LockOverlay/LockLabel

func _ready() -> void:
	panel.gui_input.connect(_on_panel_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(data: CharacterData) -> void:
	character_data = data

	if not is_node_ready():
		await ready

	portrait.texture = data.portrait
	name_label.text = data.character_name
	passive_label.text = data.passive_description

	# Apply high contrast mode
	if StatsManager.high_contrast:
		name_label.add_theme_color_override("font_color", Color.WHITE)
		passive_label.add_theme_color_override("font_color", Color.WHITE)
		select_hint.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		# Make panel border brighter
		var style = panel.get_theme_stylebox("panel").duplicate()
		if style is StyleBoxFlat:
			style.border_color = Color(0.8, 0.7, 1.0)
			style.border_width_left = 4
			style.border_width_top = 4
			style.border_width_right = 4
			style.border_width_bottom = 4
			panel.add_theme_stylebox_override("panel", style)

	if data.is_unlocked:
		lock_overlay.hide()
		select_hint.show()
	else:
		lock_overlay.show()
		lock_label.text = "LOCKED\n%d XP" % data.unlock_cost
		select_hint.hide()

func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			character_clicked.emit(character_data)

func _on_mouse_entered() -> void:
	if character_data and character_data.is_unlocked:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
