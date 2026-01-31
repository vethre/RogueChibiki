extends Control

# Left panel
@onready var back_button: Button = $MainHBox/LeftPanel/LeftMargin/LeftVBox/BackButton
@onready var skins_grid: GridContainer = $MainHBox/LeftPanel/LeftMargin/LeftVBox/ScrollContainer/SkinsGrid
@onready var bouquet_label: Label = $MainHBox/LeftPanel/LeftMargin/LeftVBox/BouquetContainer/BouquetLabel

# Right panel (preview)
@onready var skin_name_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/SkinName
@onready var character_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/CharacterLabel
@onready var skin_sprite: TextureRect = $MainHBox/RightPanel/RightMargin/PreviewVBox/SpriteContainer/SkinSprite
@onready var description_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/DescriptionLabel
@onready var cost_label: Label = $MainHBox/RightPanel/RightMargin/PreviewVBox/CostLabel
@onready var buy_button: Button = $MainHBox/RightPanel/RightMargin/PreviewVBox/BuyButton

var selected_skin_id: String = ""
var skin_buttons: Array[Button] = []

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	buy_button.pressed.connect(_on_buy_pressed)
	GameManager.bouquets_changed.connect(_update_bouquets)
	Localization.locale_changed.connect(_on_locale_changed)

	_update_bouquets(GameManager.get_bouquets())
	_populate_skins()

	# Select first skin by default
	var skin_ids = GameManager.AVAILABLE_SKINS.keys()
	if skin_ids.size() > 0:
		_select_skin(skin_ids[0])

	_animate_entrance()

func _on_locale_changed(_new_locale: String) -> void:
	_populate_skins()
	_update_preview()

func _animate_entrance() -> void:
	# Fade in and scale entrance animation
	for btn in skin_buttons:
		btn.modulate.a = 0
		btn.scale = Vector2(0.8, 0.8)
		btn.pivot_offset = btn.size / 2

	skin_sprite.modulate.a = 0
	skin_sprite.scale = Vector2(0.9, 0.9)

	await get_tree().create_timer(0.1).timeout

	# Animate buttons sequentially
	for i in range(skin_buttons.size()):
		var btn = skin_buttons[i]
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(btn, "modulate:a", 1.0, 0.3).set_delay(i * 0.1)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.3).set_delay(i * 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Animate preview
	var preview_tween = create_tween()
	preview_tween.set_parallel(true)
	preview_tween.tween_property(skin_sprite, "modulate:a", 1.0, 0.4).set_delay(0.2)
	preview_tween.tween_property(skin_sprite, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _update_bouquets(amount: int) -> void:
	bouquet_label.text = str(amount)

func _populate_skins() -> void:
	# Clear existing
	for child in skins_grid.get_children():
		child.queue_free()
	skin_buttons.clear()

	# Add skin thumbnail buttons
	for skin_id in GameManager.AVAILABLE_SKINS:
		var skin_data = GameManager.AVAILABLE_SKINS[skin_id]
		var btn = _create_skin_thumbnail(skin_id, skin_data)
		skins_grid.add_child(btn)
		skin_buttons.append(btn)

func _create_skin_thumbnail(skin_id: String, skin_data: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(140, 160)  # Bigger thumbnails

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)

	# Preview portrait - bigger
	var portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(110, 110)  # Bigger portrait
	if skin_data.has("preview"):
		portrait.texture = load(skin_data.preview)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# Apply spring tint to show it's a skin variant
	portrait.modulate = Color(1.0, 0.9, 0.95, 1)

	var is_owned = GameManager.is_skin_unlocked(skin_id)
	if is_owned:
		# Owned indicator - green border effect
		portrait.modulate = Color(0.9, 1.0, 0.95, 1)

	vbox.add_child(portrait)

	# Name label - bigger font
	var name_label = Label.new()
	name_label.text = Localization.skin_name(skin_id).replace("Spring ", "")
	name_label.add_theme_font_size_override("font_size", 14)  # Bigger text
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.95, 1))
	vbox.add_child(name_label)

	# Status label - bigger font
	var status_label = Label.new()
	if is_owned:
		status_label.text = Localization.t("SKINS_OWNED")
		status_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6, 1))
	else:
		status_label.text = "%d 🌸" % skin_data.cost
		status_label.add_theme_color_override("font_color", Color(1, 0.8, 0.85, 1))
	status_label.add_theme_font_size_override("font_size", 13)  # Bigger text
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(status_label)

	btn.add_child(vbox)
	btn.pressed.connect(_on_skin_thumbnail_pressed.bind(skin_id))

	# Add hover animation
	btn.mouse_entered.connect(_on_skin_hover.bind(btn, true))
	btn.mouse_exited.connect(_on_skin_hover.bind(btn, false))

	return btn

func _on_skin_hover(btn: Button, is_hovering: bool) -> void:
	var tween = create_tween()
	if is_hovering:
		tween.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.15).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT)

func _on_skin_thumbnail_pressed(skin_id: String) -> void:
	AudioManager.play_card_pickup()
	_select_skin(skin_id)

func _select_skin(skin_id: String) -> void:
	selected_skin_id = skin_id
	_update_preview()
	_update_thumbnail_selection()

func _update_thumbnail_selection() -> void:
	var skin_ids = GameManager.AVAILABLE_SKINS.keys()
	for i in range(skin_buttons.size()):
		var btn = skin_buttons[i]
		var id = skin_ids[i]

		if id == selected_skin_id:
			btn.modulate = Color(1.2, 1.1, 1.2)
		else:
			btn.modulate = Color(1, 1, 1)

func _update_preview() -> void:
	if selected_skin_id == "" or not GameManager.AVAILABLE_SKINS.has(selected_skin_id):
		skin_name_label.text = Localization.t("SKINS_TITLE")
		character_label.text = ""
		skin_sprite.texture = null
		description_label.text = ""
		cost_label.text = ""
		buy_button.visible = false
		return

	var skin_data = GameManager.AVAILABLE_SKINS[selected_skin_id]
	var is_owned = GameManager.is_skin_unlocked(selected_skin_id)

	# Update preview panel - use translation or fall back to data
	skin_name_label.text = Localization.skin_name(selected_skin_id)
	character_label.text = Localization.t("SKINS_FOR", [Localization.char_name(skin_data.character)])

	if skin_data.has("preview"):
		skin_sprite.texture = load(skin_data.preview)
		# Apply spring tint
		skin_sprite.modulate = Color(1.0, 0.95, 1.0, 1)

	# Try translated description
	var desc_key = "SKIN_" + selected_skin_id.to_upper() + "_DESC"
	var translated_desc = Localization.t(desc_key)
	description_label.text = translated_desc if translated_desc != desc_key else skin_data.get("description", "")

	# Handle owned/not owned state
	if is_owned:
		cost_label.text = ""
		buy_button.text = Localization.t("SKINS_OWNED")
		buy_button.disabled = true

		# Purple/owned style
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.3, 0.25, 0.4, 1)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.6, 0.5, 0.8, 1)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		buy_button.add_theme_stylebox_override("normal", style)
	else:
		cost_label.text = Localization.t("SKINS_COST", [skin_data.cost])

		var can_afford = GameManager.get_bouquets() >= skin_data.cost
		if can_afford:
			buy_button.text = Localization.t("SKINS_BUY")
			buy_button.disabled = false
		else:
			buy_button.text = Localization.t("SKINS_NOT_ENOUGH")
			buy_button.disabled = true

		# Pink/buy style
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.5, 0.25, 0.4, 1) if can_afford else Color(0.3, 0.2, 0.25, 1)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(1, 0.6, 0.8, 1) if can_afford else Color(0.5, 0.4, 0.45, 1)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		buy_button.add_theme_stylebox_override("normal", style)

	buy_button.visible = true

func _on_buy_pressed() -> void:
	if selected_skin_id == "":
		return

	AudioManager.play_card_pickup()

	if GameManager.unlock_skin(selected_skin_id):
		# Play purchase celebration animation
		_animate_purchase()
		await get_tree().create_timer(0.5).timeout
		_populate_skins()
		_update_preview()

func _animate_purchase() -> void:
	# Flash and scale the preview sprite
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(skin_sprite, "modulate", Color(2, 2, 2, 1), 0.15)
	tween.tween_property(skin_sprite, "scale", Vector2(1.15, 1.15), 0.15).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(skin_sprite, "modulate", Color(1, 0.95, 1, 1), 0.3)
	tween.tween_property(skin_sprite, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_IN_OUT)

	# Pulse the buy button
	var btn_tween = create_tween()
	btn_tween.tween_property(buy_button, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_OUT)
	btn_tween.tween_property(buy_button, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN_OUT)

func _on_back_pressed() -> void:
	AudioManager.play_card_pickup()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
