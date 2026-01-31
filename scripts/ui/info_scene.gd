extends Control

@onready var back_button: Button = $SafeArea/MainVBox/BackButton
@onready var title_label: Label = $SafeArea/MainVBox/TitleLabel
@onready var tab_container: TabContainer = $SafeArea/MainVBox/TabContainer

# Character tab
@onready var characters_container: VBoxContainer = $SafeArea/MainVBox/TabContainer/Characters/CharactersScroll/CharactersContent

# Cards tab
@onready var cards_container: VBoxContainer = $SafeArea/MainVBox/TabContainer/Cards/CardsScroll/CardsContent

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_apply_localization()
	_populate_characters()
	_populate_cards()
	_animate_entrance()

	Localization.locale_changed.connect(_on_locale_changed)

func _on_locale_changed(_new_locale: String) -> void:
	_apply_localization()

func _apply_localization() -> void:
	title_label.text = Localization.t("INFO_TITLE")
	back_button.text = Localization.t("INFO_BACK")

func _populate_characters() -> void:
	for child in characters_container.get_children():
		child.queue_free()

	for character in GameManager.all_characters:
		var char_panel = _create_character_entry(character)
		characters_container.add_child(char_panel)

func _create_character_entry(character: CharacterData) -> PanelContainer:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.18, 0.9)
	style.border_color = Color(0.5, 0.4, 0.7, 0.8)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)

	# Portrait
	var portrait = TextureRect.new()
	portrait.texture = character.portrait
	portrait.custom_minimum_size = Vector2(60, 60)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(portrait)

	# Info VBox
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(vbox)

	# Name
	var name_label = Label.new()
	name_label.text = Localization.char_name(character.character_name)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.5, 1))
	vbox.add_child(name_label)

	# Stats row
	var stats_label = Label.new()
	stats_label.text = "HP: %d | Energy: %d" % [character.starting_hp, character.starting_energy]
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 1))
	vbox.add_child(stats_label)

	# Passive
	var passive_label = Label.new()
	passive_label.text = Localization.char_passive(character.character_name)
	if passive_label.text.is_empty():
		passive_label.text = character.passive_description
	passive_label.add_theme_font_size_override("font_size", 13)
	passive_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7, 1))
	passive_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(passive_label)

	# Unlock cost
	if character.unlock_cost > 0:
		var cost_label = Label.new()
		cost_label.text = Localization.t("CHAR_UNLOCK_COST", [character.unlock_cost])
		cost_label.add_theme_font_size_override("font_size", 12)
		cost_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.4, 1))
		vbox.add_child(cost_label)

	return panel

func _populate_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()

	# Get all cards from GameManager constants
	var all_cards = [
		GameManager.CARD_STRIKE,
		GameManager.CARD_DEFEND,
		GameManager.CARD_IRON_WALL,
		GameManager.CARD_RAGE,
		GameManager.CARD_WEAKEN,
		GameManager.CARD_QUICK_DRAW,
		GameManager.CARD_OVERCHARGE,
		GameManager.CARD_FORTIFY,
		GameManager.CARD_RECKLESS_STRIKE,
		GameManager.CARD_MIND_CRUSH,
		GameManager.CARD_FLURRY,
		GameManager.CARD_GOLDEN_OPPORTUNITY,
		GameManager.CARD_ALL_IN,
		GameManager.CARD_DRAIN_LIFE,
		GameManager.CARD_PRECISE_STRIKE,
	]

	for card in all_cards:
		var card_panel = _create_card_entry(card)
		cards_container.add_child(card_panel)

func _create_card_entry(card: CardData) -> PanelContainer:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()

	# Color based on card type
	match card.card_type:
		CardData.CardType.ATTACK:
			style.bg_color = Color(0.18, 0.08, 0.08, 0.9)
			style.border_color = Color(0.8, 0.4, 0.4, 0.8)
		CardData.CardType.DEFEND:
			style.bg_color = Color(0.08, 0.12, 0.18, 0.9)
			style.border_color = Color(0.4, 0.6, 0.9, 0.8)
		CardData.CardType.SKILL:
			style.bg_color = Color(0.12, 0.15, 0.08, 0.9)
			style.border_color = Color(0.6, 0.8, 0.4, 0.8)
		_:
			style.bg_color = Color(0.1, 0.08, 0.15, 0.9)
			style.border_color = Color(0.6, 0.5, 0.8, 0.8)

	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	# Card info
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 3)
	hbox.add_child(vbox)

	# Name and cost row
	var name_row = HBoxContainer.new()
	vbox.add_child(name_row)

	var name_label = Label.new()
	name_label.text = Localization.card_name(card.card_name)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8, 1))
	name_row.add_child(name_label)

	var cost_label = Label.new()
	cost_label.text = "%d Energy" % card.energy_cost
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.4, 1))
	name_row.add_child(cost_label)

	# Type
	var type_label = Label.new()
	var type_text = ""
	match card.card_type:
		CardData.CardType.ATTACK:
			type_text = Localization.t("CARD_ATTACK")
		CardData.CardType.DEFEND:
			type_text = Localization.t("CARD_DEFEND")
		CardData.CardType.SKILL:
			type_text = Localization.t("CARD_SKILL")
		CardData.CardType.POWER:
			type_text = Localization.t("CARD_POWER")
	type_label.text = type_text
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1))
	vbox.add_child(type_label)

	# Description
	var desc_label = Label.new()
	var card_desc = Localization.card_desc(card.card_name)
	desc_label.text = card_desc if not card_desc.is_empty() else card.description
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9, 1))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	return panel

func _animate_entrance() -> void:
	var info_panel = $SafeArea/MainVBox/TabContainer

	title_label.modulate.a = 0
	info_panel.modulate.a = 0
	back_button.modulate.a = 0

	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.3)
	tween.tween_property(info_panel, "modulate:a", 1.0, 0.4)
	tween.tween_property(back_button, "modulate:a", 1.0, 0.2)

func _on_back_pressed() -> void:
	AudioManager.play_card_pickup()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
