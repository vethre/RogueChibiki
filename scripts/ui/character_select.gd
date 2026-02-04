extends Control

# Left panel
@onready var back_button: Button = $MainHBox/LeftPanel/LeftMargin/LeftVBox/BackButton
@onready var characters_grid: GridContainer = $MainHBox/LeftPanel/LeftMargin/LeftVBox/ScrollContainer/CharactersGrid
@onready var xp_label: Label = $MainHBox/LeftPanel/LeftMargin/LeftVBox/XPLabel

# Right panel (preview)
@onready var character_name_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/CharacterName
@onready var character_sprite: TextureRect = $MainHBox/RightPanel/RightMargin/PreviewVBox/SpriteContainer/CharacterSprite
@onready var sprite_container: CenterContainer = $MainHBox/RightPanel/RightMargin/PreviewVBox/SpriteContainer
@onready var passive_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/PassiveLabel
@onready var hp_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/StatsHBox/HPLabel
@onready var energy_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/StatsHBox/EnergyLabel
@onready var deck_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/StatsHBox/DeckLabel
@onready var unlock_cost_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/UnlockCostLabel
@onready var start_button: Button = $MainHBox/RightPanel/RightMargin/PreviewVBox/StartButton

var selected_character: CharacterData = null
var character_buttons: Array[Button] = []
var skin_selector: HBoxContainer = null
var current_skin_id: String = "default"

# Seed system UI
var seed_popup: Panel = null
var seed_input: LineEdit = null
var seed_display_label: Label = null

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	start_button.pressed.connect(_on_start_pressed)

	# Refresh UI when language changes
	Localization.locale_changed.connect(_on_locale_changed)

	_populate_characters()
	_update_xp_display()

	# Select first unlocked character by default
	for character in GameManager.all_characters:
		if character.is_unlocked:
			_select_character(character)
			break

func _on_locale_changed(_new_locale: String) -> void:
	_populate_characters()
	_update_preview()
	_update_xp_display()

func _create_skin_selector() -> void:
	# Remove existing skin selector if any
	if skin_selector:
		skin_selector.queue_free()
		skin_selector = null

	if not selected_character or not selected_character.is_unlocked:
		return

	# Get available skins for this character
	var skins = GameManager.get_all_skins_for_character(selected_character.character_name)
	if skins.size() <= 1:
		return  # Only default skin, no need for selector

	# Create skin selector container
	skin_selector = HBoxContainer.new()
	skin_selector.alignment = BoxContainer.ALIGNMENT_CENTER
	skin_selector.add_theme_constant_override("separation", 8)

	# Add skin label
	var skin_label = Label.new()
	skin_label.text = Localization.t("MENU_SKINS") + ":"
	skin_label.add_theme_font_size_override("font_size", 14)
	skin_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	skin_selector.add_child(skin_label)

	# Create buttons for each skin
	for skin in skins:
		var btn = Button.new()
		btn.text = skin.name if skin.id == "default" else Localization.skin_name(skin.id)
		btn.custom_minimum_size = Vector2(80, 32)
		btn.add_theme_font_size_override("font_size", 12)

		if not skin.unlocked:
			btn.disabled = true
			btn.tooltip_text = Localization.t("SKINS_NOT_ENOUGH")
		else:
			btn.pressed.connect(_on_skin_selected.bind(skin.id))

		# Highlight current selection
		if skin.id == current_skin_id:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.3, 0.5, 0.4, 1)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(0.5, 0.9, 0.6, 1)
			style.corner_radius_top_left = 6
			style.corner_radius_top_right = 6
			style.corner_radius_bottom_left = 6
			style.corner_radius_bottom_right = 6
			btn.add_theme_stylebox_override("normal", style)

		skin_selector.add_child(btn)

	# Insert after sprite container
	var preview_vbox = sprite_container.get_parent()
	var sprite_index = sprite_container.get_index()
	preview_vbox.add_child(skin_selector)
	preview_vbox.move_child(skin_selector, sprite_index + 1)

func _on_skin_selected(skin_id: String) -> void:
	AudioManager.play_card_pickup()
	current_skin_id = skin_id
	GameManager.select_skin(selected_character.character_name, skin_id)
	_update_character_sprite()
	_create_skin_selector()  # Refresh to update selection highlight

func _update_character_sprite() -> void:
	if not selected_character:
		character_sprite.texture = null
		return

	# Check if using a skin
	if current_skin_id != "default" and current_skin_id in GameManager.AVAILABLE_SKINS:
		var skin_data = GameManager.AVAILABLE_SKINS[current_skin_id]
		if GameManager.is_skin_unlocked(current_skin_id):
			var skin_texture = load(skin_data.preview)
			if skin_texture:
				character_sprite.texture = skin_texture
				return

	# Default to character portrait
	character_sprite.texture = selected_character.portrait

func _populate_characters() -> void:
	# Clear existing
	for child in characters_grid.get_children():
		child.queue_free()
	character_buttons.clear()

	# Add character thumbnail buttons
	for character in GameManager.all_characters:
		var btn = _create_character_thumbnail(character)
		characters_grid.add_child(btn)
		character_buttons.append(btn)

func _get_character_icon_path(character_name: String) -> String:
	# Map character names to icon files
	# Note: Use "Icons" (capital I) to match actual folder name on case-sensitive filesystems (Android)
	var icon_map = {
		"Murzik": "res://assets/Icons/Murzik_Icon.png",
		"Dangerlyoha": "res://assets/Icons/Dangerlyoha_Icon.png",
		"Morpheya": "res://assets/Icons/Morpheya_Icon.png",
		"Yuuechka": "res://assets/Icons/Yuuechka_Icon.png",
		"Evelone": "res://assets/Icons/Evelone_Icon.png",
		"Buster": "res://assets/Icons/Buster_Icon.png",
		"Mokrivskyi": "res://assets/Icons/Mokrivskyi_Icon.png",
		"Chriswave": "res://assets/Icons/Chriswave_Icon.png",
		"Gaechka": "res://assets/Icons/Gaechka_Icon.png",
		"ByOwl": "res://assets/Icons/ByOwl_Icon.PNG",
		"Morphi Yuke": "res://assets/Icons/Morphi_Icon.PNG",
		"KoryaMC": "res://assets/Icons/Korya_Icon.png"
	}
	return icon_map.get(character_name, "")

func _is_character_playable(character: CharacterData) -> bool:
	if character.is_unlocked:
		return true
	# Special case: Chriswave trial system
	if character.character_name == "Chriswave" and StatsManager.has_chriswave_trials():
		return true
	return false

func _create_character_thumbnail(character: CharacterData) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(100, 100)

	var is_playable = _is_character_playable(character)

	# Use flat transparent style for cleaner icon look
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.15, 0.6)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	# Special gold border for trial character
	if character.character_name == "Chriswave" and not character.is_unlocked and StatsManager.has_chriswave_trials():
		style.border_color = Color(1, 0.8, 0.3, 0.9)
	else:
		style.border_color = Color(0.4, 0.35, 0.5, 0.8) if is_playable else Color(0.3, 0.3, 0.3, 0.6)
	btn.add_theme_stylebox_override("normal", style)

	# Hover style
	var hover_style = style.duplicate()
	if character.character_name == "Chriswave" and not character.is_unlocked and StatsManager.has_chriswave_trials():
		hover_style.border_color = Color(1, 0.9, 0.5, 1)
	else:
		hover_style.border_color = Color(0.6, 0.5, 0.8, 1) if is_playable else Color(0.4, 0.4, 0.4, 0.8)
	hover_style.bg_color = Color(0.15, 0.12, 0.2, 0.8)
	btn.add_theme_stylebox_override("hover", hover_style)

	var container = CenterContainer.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Character icon
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(85, 85)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Load character icon
	var icon_path = _get_character_icon_path(character.character_name)
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
	else:
		# Fallback to portrait if icon not found
		icon.texture = character.portrait

	# Locked state (but not for trial characters)
	if not is_playable:
		icon.modulate = Color(0.35, 0.35, 0.35, 0.9)

	container.add_child(icon)
	btn.add_child(container)

	# Lock overlay for locked characters (but not trial characters)
	if not is_playable:
		var lock_overlay = Label.new()
		lock_overlay.text = "🔒"
		lock_overlay.add_theme_font_size_override("font_size", 20)
		lock_overlay.set_anchors_preset(Control.PRESET_CENTER)
		lock_overlay.position = Vector2(-10, -10)
		lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(lock_overlay)

	# Trial badge for Chriswave
	if character.character_name == "Chriswave" and not character.is_unlocked and StatsManager.has_chriswave_trials():
		var trial_badge = Label.new()
		trial_badge.text = "TRIAL"
		trial_badge.add_theme_font_size_override("font_size", 10)
		trial_badge.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 1))
		trial_badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		trial_badge.position = Vector2(-35, -18)
		trial_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(trial_badge)

	btn.pressed.connect(_on_character_thumbnail_pressed.bind(character))

	return btn

func _on_character_thumbnail_pressed(character: CharacterData) -> void:
	AudioManager.play_card_pickup()
	_select_character(character)

func _select_character(character: CharacterData) -> void:
	selected_character = character
	# Load saved skin for this character
	current_skin_id = GameManager.get_selected_skin(character.character_name)
	_update_preview()
	_update_thumbnail_selection()

func _update_thumbnail_selection() -> void:
	# Update button styles to show selection
	for i in range(character_buttons.size()):
		var btn = character_buttons[i]
		var character = GameManager.all_characters[i]

		if character == selected_character:
			btn.modulate = Color(1.2, 1.2, 1.0)
		else:
			btn.modulate = Color(1, 1, 1)

func _update_preview() -> void:
	# Clean up skin selector when no character selected
	if skin_selector:
		skin_selector.queue_free()
		skin_selector = null

	if not selected_character:
		character_name_label.text = Localization.t("CHAR_SELECT_TITLE")
		character_sprite.texture = null
		passive_label.text = ""
		hp_label.text = ""
		energy_label.text = ""
		deck_label.text = ""
		unlock_cost_label.text = ""
		start_button.visible = false
		return

	# Update preview panel
	character_name_label.text = Localization.char_name(selected_character.character_name)
	_update_character_sprite()
	_create_skin_selector()

	# Try translated passive, fall back to resource value
	var translated_passive = Localization.char_passive(selected_character.character_name)
	passive_label.text = translated_passive if translated_passive != "" else selected_character.passive_description

	hp_label.text = Localization.t("CHAR_HP", [selected_character.starting_hp])
	energy_label.text = Localization.t("CHAR_ENERGY", [selected_character.starting_energy])

	var deck_size = selected_character.strike_count + selected_character.defend_count + selected_character.special_cards.size()
	deck_label.text = Localization.t("CHAR_DECK", [deck_size])

	# Handle locked/unlocked/trial state
	var is_chriswave_trial = selected_character.character_name == "Chriswave" and not selected_character.is_unlocked and StatsManager.has_chriswave_trials()

	if selected_character.is_unlocked:
		unlock_cost_label.text = ""
		start_button.text = Localization.t("CHAR_START_RUN")
		start_button.disabled = false

		# Green style for start
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.5, 0.3, 1)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.4, 0.9, 0.5, 1)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		start_button.add_theme_stylebox_override("normal", style)

		character_sprite.modulate = Color.WHITE
	elif is_chriswave_trial:
		# Chriswave trial mode
		unlock_cost_label.text = Localization.t("CHAR_TRIAL_REMAINING", [StatsManager.get_chriswave_trials()])
		start_button.text = Localization.t("CHAR_START_TRIAL")
		start_button.disabled = false

		# Special gold/purple style for trial
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.4, 0.3, 0.5, 1)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(1, 0.8, 0.5, 1)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		start_button.add_theme_stylebox_override("normal", style)

		character_sprite.modulate = Color.WHITE
	else:
		unlock_cost_label.text = Localization.t("CHAR_UNLOCK_COST", [selected_character.unlock_cost])

		var can_afford = GameManager.player_xp >= selected_character.unlock_cost
		if can_afford:
			start_button.text = Localization.t("CHAR_UNLOCK")
			start_button.disabled = false
		else:
			start_button.text = Localization.t("CHAR_NOT_ENOUGH_XP")
			start_button.disabled = true

		# Gold/orange style for unlock
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.5, 0.35, 0.15, 1) if can_afford else Color(0.3, 0.25, 0.2, 1)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(1, 0.8, 0.3, 1) if can_afford else Color(0.5, 0.4, 0.3, 1)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		start_button.add_theme_stylebox_override("normal", style)

		character_sprite.modulate = Color(0.6, 0.6, 0.6, 1)

	start_button.visible = true

func _on_start_pressed() -> void:
	if not selected_character:
		return

	AudioManager.play_card_pickup()

	var is_chriswave_trial = selected_character.character_name == "Chriswave" and not selected_character.is_unlocked and StatsManager.has_chriswave_trials()

	if selected_character.is_unlocked or is_chriswave_trial:
		# Show seed selection popup
		_show_seed_popup(is_chriswave_trial)
	else:
		# Try to unlock
		if GameManager.spend_xp(selected_character.unlock_cost):
			selected_character.is_unlocked = true
			GameManager.save_data()
			_populate_characters()
			_update_preview()
			_update_xp_display()

func _show_seed_popup(is_trial: bool = false) -> void:
	if seed_popup:
		seed_popup.queue_free()

	seed_popup = Panel.new()
	seed_popup.set_anchors_preset(Control.PRESET_FULL_RECT)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.02, 0.06, 0.95)
	seed_popup.add_theme_stylebox_override("panel", style)
	add_child(seed_popup)

	# Main container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	seed_popup.add_child(center)

	var card = Panel.new()
	card.custom_minimum_size = Vector2(320, 340)

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.08, 0.06, 0.12, 0.98)
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.6, 0.5, 0.9, 0.9)
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	card.add_theme_stylebox_override("panel", card_style)
	center.add_child(card)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 14)
	card.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "RUN SETTINGS"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Seed section
	var seed_label = Label.new()
	seed_label.text = "Enter Seed (optional):"
	seed_label.add_theme_font_size_override("font_size", 14)
	seed_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(seed_label)

	seed_input = LineEdit.new()
	seed_input.placeholder_text = "Leave empty for random"
	seed_input.custom_minimum_size = Vector2(0, 40)
	seed_input.add_theme_font_size_override("font_size", 16)
	seed_input.max_length = 12
	seed_input.alignment = HORIZONTAL_ALIGNMENT_CENTER

	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.12, 0.1, 0.18)
	input_style.border_width_left = 2
	input_style.border_width_top = 2
	input_style.border_width_right = 2
	input_style.border_width_bottom = 2
	input_style.border_color = Color(0.4, 0.35, 0.6)
	input_style.corner_radius_top_left = 8
	input_style.corner_radius_top_right = 8
	input_style.corner_radius_bottom_left = 8
	input_style.corner_radius_bottom_right = 8
	seed_input.add_theme_stylebox_override("normal", input_style)
	vbox.add_child(seed_input)

	# Hint
	var hint = Label.new()
	hint.text = "Seeded runs use fixed RNG for\nreproducible runs (like Balatro)"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Buttons container
	var btn_container = VBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_container)

	# Start Run button
	var start_btn = Button.new()
	start_btn.text = "START RUN"
	start_btn.custom_minimum_size = Vector2(0, 50)
	start_btn.add_theme_font_size_override("font_size", 18)
	start_btn.pressed.connect(_on_seed_confirmed.bind(is_trial))
	_style_seed_button(start_btn, Color(0.3, 0.6, 0.4), Color(0.5, 0.9, 0.6))
	btn_container.add_child(start_btn)

	# Cancel button
	var cancel_btn = Button.new()
	cancel_btn.text = "Back"
	cancel_btn.custom_minimum_size = Vector2(0, 40)
	cancel_btn.add_theme_font_size_override("font_size", 14)
	cancel_btn.pressed.connect(_close_seed_popup)
	_style_seed_button(cancel_btn, Color(0.25, 0.2, 0.3), Color(0.5, 0.45, 0.6))
	btn_container.add_child(cancel_btn)

	# Animate entrance
	seed_popup.modulate.a = 0
	card.scale = Vector2(0.9, 0.9)
	card.pivot_offset = card.size / 2

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(seed_popup, "modulate:a", 1.0, 0.2)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _style_seed_button(btn: Button, bg_color: Color, border_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(bg_color.r + 0.1, bg_color.g + 0.1, bg_color.b + 0.1)
	btn.add_theme_stylebox_override("hover", hover)

func _on_seed_confirmed(is_trial: bool) -> void:
	var custom_seed = seed_input.text.strip_edges().to_upper() if seed_input else ""
	_close_seed_popup()

	if is_trial:
		StatsManager.use_chriswave_trial()

	GameManager.select_character(selected_character)
	RunManager.start_new_run(selected_character, custom_seed)

func _close_seed_popup() -> void:
	if seed_popup:
		var tween = create_tween()
		tween.tween_property(seed_popup, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func():
			if seed_popup:
				seed_popup.queue_free()
				seed_popup = null
		)

func _update_xp_display() -> void:
	xp_label.text = Localization.t("COMMON_XP", [GameManager.player_xp])

func _on_back_pressed() -> void:
	AudioManager.play_card_pickup()
	VFXManager.transition_to_scene("res://scenes/ui/main_menu.tscn")
