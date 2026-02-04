extends Control

# Card pool for shop - includes ALL available cards
const ALL_CARDS = [
	# Basic cards
	preload("res://data/card_strike.tres"),
	preload("res://data/card_defend.tres"),
	preload("res://data/card_iron_wall.tres"),
	preload("res://data/card_rage.tres"),
	preload("res://data/card_weaken.tres"),
	preload("res://data/card_quick_draw.tres"),
	# Uncommon cards
	preload("res://data/card_fortify.tres"),
	preload("res://data/card_overcharge.tres"),
	preload("res://data/card_precise_strike.tres"),
	preload("res://data/card_flurry.tres"),
	preload("res://data/card_mind_crush.tres"),
	preload("res://data/card_golden_opportunity.tres"),
	preload("res://data/card_reckless_strike.tres"),
	preload("res://data/card_drain_life.tres"),
	preload("res://data/card_all_in.tres"),
	# New cards
	preload("res://data/card_balance_strike.tres"),
	preload("res://data/card_fury.tres"),
	preload("res://data/card_spike_armor.tres"),
]

# Upgrade definitions
const UPGRADES = [
	{"id": "energy", "name": "Energy Crystal", "desc": "+1 Energy/turn", "cost": 80, "value": 1, "color": Color(1, 0.9, 0.3)},
	{"id": "draw", "name": "Card Mastery", "desc": "+1 Card draw", "cost": 65, "value": 1, "color": Color(0.4, 0.8, 1)},
	{"id": "damage", "name": "Sharp Blade", "desc": "+2 Attack dmg", "cost": 45, "value": 2, "color": Color(1, 0.4, 0.4)},
	{"id": "block", "name": "Iron Shield", "desc": "+2 Block", "cost": 45, "value": 2, "color": Color(0.4, 0.6, 1)},
	{"id": "max_hp", "name": "Vitality Orb", "desc": "+10 Max HP", "cost": 40, "value": 10, "color": Color(1, 0.4, 0.6)},
	{"id": "heal_on_kill", "name": "Life Steal", "desc": "+3 HP on kill", "cost": 55, "value": 3, "color": Color(0.8, 0.3, 0.8)},
	{"id": "gold", "name": "Golden Touch", "desc": "+10% Gold", "cost": 30, "value": 1, "color": Color(1, 0.85, 0.2)},
]

# Cozy color palette
const COLOR_WARM_GOLD = Color(1.0, 0.92, 0.55)
const COLOR_SOFT_GREEN = Color(0.5, 0.95, 0.6)
const COLOR_LAVENDER = Color(0.75, 0.65, 0.95)
const COLOR_CORAL = Color(1.0, 0.55, 0.5)
const COLOR_SKY_BLUE = Color(0.5, 0.8, 1.0)
const COLOR_MINT = Color(0.6, 1.0, 0.8)
const COLOR_PEACH = Color(1.0, 0.8, 0.7)

# Base pack prices (scale with stage)
const UPG_PACK_BASE_COST: int = 60
const CARD_PACK_BASE_COST: int = 50
const UPGRADE_CARD_BASE_COST: int = 30

func _get_upg_pack_cost() -> int:
	return int(UPG_PACK_BASE_COST * (1.0 + (RunManager.current_stage - 1) * 0.1))

func _get_card_pack_cost() -> int:
	return int(CARD_PACK_BASE_COST * (1.0 + (RunManager.current_stage - 1) * 0.1))

func _get_upgrade_card_cost() -> int:
	return int(UPGRADE_CARD_BASE_COST * (1.0 + (RunManager.current_stage - 1) * 0.1))

# Pack icons
const UPG_PACK_ICON = preload("res://assets/UPGPackIcon.png")
const CARD_PACK_ICON = preload("res://assets/CardPackIcon.png")

# Upg Pack chances (40% Remove, 40% Upgrade, 20% Relic)
const CHANCE_REMOVE: float = 0.4
const CHANCE_UPGRADE: float = 0.4

# UI References - Left Panel
@onready var portrait: TextureRect = $"SafeArea/MainVBox/ContentHBox/LeftPanel/LeftMargin/LeftContent/Portrait"
@onready var hp_bar: ProgressBar = $"SafeArea/MainVBox/ContentHBox/LeftPanel/LeftMargin/LeftContent/HPContainer/HPBar"
@onready var hp_label: Label = $"SafeArea/MainVBox/ContentHBox/LeftPanel/LeftMargin/LeftContent/HPContainer/HPLabel"
@onready var gold_label: Label = $"SafeArea/MainVBox/ContentHBox/LeftPanel/LeftMargin/LeftContent/GoldContainer/GoldLabel"
@onready var coin_icon: TextureRect = $"SafeArea/MainVBox/ContentHBox/LeftPanel/LeftMargin/LeftContent/GoldContainer/CoinIcon"
@onready var heal_btn: Button = $"SafeArea/MainVBox/ContentHBox/LeftPanel/LeftMargin/LeftContent/HealBtn"
@onready var left_panel: PanelContainer = $"SafeArea/MainVBox/ContentHBox/LeftPanel"

# UI References - Top Bar
@onready var menu_btn: Button = $"SafeArea/MainVBox/TopBar/MenuBtn"
@onready var stage_label: Label = $"SafeArea/MainVBox/TopBar/StageLabel"
@onready var score_label: Label = $"SafeArea/MainVBox/TopBar/ScoreLabel"

# UI References - Right Panel (new layout: packs on top, cards on bottom)
@onready var upg_pack_btn: Button = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/TopRow/UpgPackBtn"
@onready var card_pack_btn: Button = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/TopRow/CardPackBtn"
@onready var upgrade_btn: Button = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/BottomRow/UpgradeBtn"
@onready var card_btn_1: Button = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/BottomRow/CardBtn1"
@onready var card_btn_2: Button = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/BottomRow/CardBtn2"
@onready var card_btn_3: Button = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/BottomRow/CardBtn3"
@onready var continue_btn: Button = $"SafeArea/MainVBox/ContinueButton"
@onready var right_panel: PanelContainer = $"SafeArea/MainVBox/ContentHBox/RightPanel"
@onready var shop_title: Label = $"SafeArea/MainVBox/ContentHBox/RightPanel/RightMargin/RightContent/ShopTitle"

# Shop state
var shop_cards: Array[Dictionary] = []
var popup_panel: Control = null

func _ready() -> void:
	_connect_signals()
	_setup_shop()
	_style_buttons()
	_update_ui()
	# Delay animation to next frame so layout is computed
	call_deferred("_play_entrance_animation")
	# Play shop music
	AudioManager.play_shop_music()

func _connect_signals() -> void:
	continue_btn.pressed.connect(_on_continue)
	menu_btn.pressed.connect(_on_menu)
	heal_btn.pressed.connect(_on_heal)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	upg_pack_btn.pressed.connect(_on_upg_pack_pressed)
	card_pack_btn.pressed.connect(_on_card_pack_pressed)

	card_btn_1.pressed.connect(_on_buy_card.bind(0))
	card_btn_2.pressed.connect(_on_buy_card.bind(1))
	card_btn_3.pressed.connect(_on_buy_card.bind(2))

func _setup_shop() -> void:
	# Generate 3 random cards for individual sale (using seeded RNG)
	var available_cards = ALL_CARDS.duplicate()
	_seeded_shuffle(available_cards)

	for i in range(3):
		var card = available_cards[i].duplicate()
		var price = _get_card_price(card)
		shop_cards.append({"card": card, "price": price, "sold": false})

	# Set character portrait
	if GameManager.selected_character:
		portrait.texture = GameManager.selected_character.portrait

func _style_buttons() -> void:
	# Style pack buttons with custom layout - big centered icon with price badge
	_style_pack_button(upg_pack_btn, UPG_PACK_ICON, COLOR_LAVENDER, "UPG")
	_style_pack_button(card_pack_btn, CARD_PACK_ICON, COLOR_SKY_BLUE, "CARD")

	# Price labels will be updated in _update_ui with scaling costs

	# Style upgrade button
	_apply_button_style(upgrade_btn, COLOR_WARM_GOLD, Color(0.25, 0.2, 0.1))

	# Style card buttons with soft colors
	_apply_button_style(card_btn_1, COLOR_CORAL, Color(0.25, 0.12, 0.12))
	_apply_button_style(card_btn_2, COLOR_MINT, Color(0.12, 0.22, 0.15))
	_apply_button_style(card_btn_3, COLOR_PEACH, Color(0.25, 0.18, 0.12))

	# Style heal button
	_apply_button_style(heal_btn, COLOR_SOFT_GREEN, Color(0.1, 0.2, 0.12))

	# Style continue button
	_apply_button_style(continue_btn, COLOR_WARM_GOLD, Color(0.2, 0.18, 0.08))

	# Style menu button
	_apply_button_style(menu_btn, COLOR_CORAL, Color(0.2, 0.1, 0.1))

	# Style HP bar
	_style_hp_bar()

	# Style top bar labels
	_style_top_bar()

func _style_top_bar() -> void:
	# Stage label style
	stage_label.add_theme_font_size_override("font_size", 14)
	stage_label.add_theme_color_override("font_color", COLOR_LAVENDER)

	# Score label style
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", COLOR_WARM_GOLD)

func _style_pack_button(btn: Button, icon_texture: Texture2D, accent_color: Color, pack_name: String) -> void:
	# Clear default button text
	btn.text = ""
	btn.icon = null

	# Create dark gradient background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.08, 0.06, 0.12, 0.95)
	bg_style.border_width_left = 3
	bg_style.border_width_top = 3
	bg_style.border_width_right = 3
	bg_style.border_width_bottom = 3
	bg_style.border_color = accent_color
	bg_style.corner_radius_top_left = 12
	bg_style.corner_radius_top_right = 12
	bg_style.corner_radius_bottom_right = 12
	bg_style.corner_radius_bottom_left = 12
	bg_style.shadow_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.3)
	bg_style.shadow_size = 4
	btn.add_theme_stylebox_override("normal", bg_style)

	# Hover style
	var hover_style = bg_style.duplicate()
	hover_style.bg_color = Color(0.12, 0.1, 0.18)
	hover_style.border_color = Color(accent_color.r + 0.15, accent_color.g + 0.15, accent_color.b + 0.15)
	btn.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = bg_style.duplicate()
	pressed_style.bg_color = Color(0.15, 0.12, 0.22)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	# Disabled style
	var disabled_style = bg_style.duplicate()
	disabled_style.bg_color = Color(0.06, 0.05, 0.08)
	disabled_style.border_color = Color(0.25, 0.25, 0.3)
	btn.add_theme_stylebox_override("disabled", disabled_style)

	# Large centered pack icon
	var pack_icon = TextureRect.new()
	pack_icon.name = "PackIcon"
	pack_icon.texture = icon_texture
	pack_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pack_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pack_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	pack_icon.offset_left = 8
	pack_icon.offset_top = 5
	pack_icon.offset_right = -8
	pack_icon.offset_bottom = -25
	pack_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(pack_icon)

	# Pack name label at top
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = pack_name + " PACK"
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", accent_color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	name_label.offset_top = 3
	name_label.offset_bottom = 18
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(name_label)

	# Price badge at bottom (styled container)
	var price_badge = Panel.new()
	price_badge.name = "PriceBadge"
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(0.15, 0.12, 0.08, 0.95)
	badge_style.border_width_left = 2
	badge_style.border_width_top = 2
	badge_style.border_width_right = 2
	badge_style.border_width_bottom = 2
	badge_style.border_color = COLOR_WARM_GOLD
	badge_style.corner_radius_top_left = 8
	badge_style.corner_radius_top_right = 8
	badge_style.corner_radius_bottom_right = 8
	badge_style.corner_radius_bottom_left = 8
	price_badge.add_theme_stylebox_override("panel", badge_style)
	price_badge.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	price_badge.offset_left = -35
	price_badge.offset_right = 35
	price_badge.offset_top = -28
	price_badge.offset_bottom = -4
	price_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(price_badge)

	# Price label inside badge
	var price_label = Label.new()
	price_label.name = "PriceLabel"
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", COLOR_WARM_GOLD)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_badge.add_child(price_label)

func _apply_button_style(btn: Button, border_color: Color, bg_color: Color) -> void:
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
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.2)
	style.shadow_size = 2
	btn.add_theme_stylebox_override("normal", style)

	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(bg_color.r + 0.1, bg_color.g + 0.1, bg_color.b + 0.1)
	hover_style.border_color = Color(border_color.r + 0.1, border_color.g + 0.1, border_color.b + 0.1)
	btn.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = style.duplicate()
	pressed_style.bg_color = Color(bg_color.r + 0.15, bg_color.g + 0.15, bg_color.b + 0.15)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	# Disabled style
	var disabled_style = style.duplicate()
	disabled_style.bg_color = Color(0.1, 0.1, 0.12)
	disabled_style.border_color = Color(0.3, 0.3, 0.35)
	btn.add_theme_stylebox_override("disabled", disabled_style)

func _style_hp_bar() -> void:
	# Background
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.1, 0.12)
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.corner_radius_bottom_right = 6
	hp_bar.add_theme_stylebox_override("background", bg_style)

	# Fill
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.4, 0.9, 0.5)
	fill_style.corner_radius_top_left = 5
	fill_style.corner_radius_top_right = 5
	fill_style.corner_radius_bottom_left = 5
	fill_style.corner_radius_bottom_right = 5
	hp_bar.add_theme_stylebox_override("fill", fill_style)

func _update_pack_price_label(btn: Button, cost: int) -> void:
	# Find the price label inside PriceBadge
	var price_badge = btn.get_node_or_null("PriceBadge")
	if price_badge:
		var price_label = price_badge.get_node_or_null("PriceLabel")
		if price_label:
			price_label.text = "%dG" % cost

func _play_entrance_animation() -> void:
	# Simple fade in (no scale - keeps layout clean)
	left_panel.modulate.a = 0
	right_panel.modulate.a = 0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(left_panel, "modulate:a", 1.0, 0.4)
	tween.tween_property(right_panel, "modulate:a", 1.0, 0.4).set_delay(0.1)

	# Animate shop title with gentle pulse
	_start_title_pulse()

	# Animate coin icon
	_start_coin_animation()

func _start_title_pulse() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(shop_title, "modulate", Color(1.1, 1.0, 0.9), 1.5)
	tween.tween_property(shop_title, "modulate", Color(1.0, 0.95, 0.85), 1.5)

func _start_coin_animation() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(coin_icon, "scale", Vector2(1.1, 1.1), 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(coin_icon, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)

func _get_card_price(card: CardData) -> int:
	var base_price = 35
	match card.card_type:
		CardData.CardType.ATTACK:
			base_price = 30
		CardData.CardType.DEFEND:
			base_price = 25
		CardData.CardType.SKILL:
			base_price = 40
		CardData.CardType.POWER:
			base_price = 55

	base_price = int(base_price * (1.0 + (RunManager.current_stage - 1) * 0.05))
	return int(base_price * RunManager.seeded_randf_range(0.85, 1.15))

func _update_ui() -> void:
	# Update HP bar and label
	hp_bar.max_value = RunManager.run_max_hp
	hp_bar.value = RunManager.run_hp
	hp_label.text = "%d / %d" % [RunManager.run_hp, RunManager.run_max_hp]

	# Color HP based on percentage
	var hp_percent = float(RunManager.run_hp) / float(RunManager.run_max_hp)
	if hp_percent > 0.6:
		hp_label.add_theme_color_override("font_color", COLOR_SOFT_GREEN)
	elif hp_percent > 0.3:
		hp_label.add_theme_color_override("font_color", COLOR_WARM_GOLD)
	else:
		hp_label.add_theme_color_override("font_color", COLOR_CORAL)

	# Update gold
	gold_label.text = "%d" % RunManager.run_gold

	# Update top bar with stage, floor, and seed info
	var seed_text = ""
	if RunManager.is_run_seeded():
		seed_text = " | Seed: %s" % RunManager.get_run_seed()
	stage_label.text = "Stage: %d | Floor: %d%s" % [RunManager.current_stage, RunManager.current_floor, seed_text]
	score_label.text = "Score: %d" % RunManager.run_score

	# Update heal button
	var heal_cost = _get_heal_cost()
	var heal_amount = int(RunManager.run_max_hp * 0.4)
	heal_btn.text = "Heal %d\n%dG" % [heal_amount, heal_cost]
	heal_btn.disabled = RunManager.run_gold < heal_cost or RunManager.run_hp >= RunManager.run_max_hp

	# Update card buttons
	_update_card_buttons()

	# Update pack buttons with scaling costs
	var upg_cost = _get_upg_pack_cost()
	var card_cost = _get_card_pack_cost()
	var upgrade_cost = _get_upgrade_card_cost()

	upg_pack_btn.tooltip_text = "Upgrade Pack - %dG" % upg_cost
	upg_pack_btn.disabled = RunManager.run_gold < upg_cost
	_update_pack_price_label(upg_pack_btn, upg_cost)

	card_pack_btn.tooltip_text = "Card Pack - %dG" % card_cost
	card_pack_btn.disabled = RunManager.run_gold < card_cost
	_update_pack_price_label(card_pack_btn, card_cost)

	# Update upgrade button (costs gold, scales with stage)
	upgrade_btn.text = "Upgrade\n%dG" % upgrade_cost
	upgrade_btn.disabled = RunManager.run_gold < upgrade_cost or RunManager.get_upgradeable_cards().is_empty()

func _update_card_buttons() -> void:
	var buttons = [card_btn_1, card_btn_2, card_btn_3]

	for i in range(3):
		var item = shop_cards[i]
		var btn = buttons[i]

		if item.sold:
			btn.text = "SOLD"
			btn.disabled = true
		else:
			btn.text = "%s\n%dG" % [item.card.card_name, item.price]
			btn.disabled = RunManager.run_gold < item.price

func _get_heal_cost() -> int:
	return 15 + RunManager.current_stage * 3

func _on_buy_card(index: int) -> void:
	var item = shop_cards[index]
	if item.sold:
		return

	if RunManager.spend_gold(item.price):
		AudioManager.play_purchase()
		RunManager.add_card_to_deck(item.card.duplicate())
		item.sold = true
		VFXManager.gold_effect(self, Vector2(size.x / 2, size.y / 2), item.price)
		_animate_purchase([card_btn_1, card_btn_2, card_btn_3][index])
		_update_ui()

func _on_heal() -> void:
	var heal_cost = _get_heal_cost()
	var heal_amount = int(RunManager.run_max_hp * 0.4)

	if RunManager.spend_gold(heal_cost):
		AudioManager.play_purchase()
		RunManager.heal(heal_amount)
		VFXManager.heal_effect(self, Vector2(size.x / 2, size.y / 2), heal_amount)
		_animate_heal()
		_update_ui()

func _animate_purchase(btn: Button) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func _animate_heal() -> void:
	var tween = create_tween()
	tween.tween_property(hp_bar, "modulate", Color(1.3, 1.5, 1.3), 0.15)
	tween.tween_property(hp_bar, "modulate", Color(1, 1, 1), 0.3)

func _on_upgrade_pressed() -> void:
	# Now shows card upgrades (free once per shop)
	_show_free_card_upgrade_popup()

func _on_upg_pack_pressed() -> void:
	var cost = _get_upg_pack_cost()
	if RunManager.run_gold < cost:
		return

	if not RunManager.spend_gold(cost):
		return

	AudioManager.play_purchase()
	_show_upg_pack_options()

func _show_upg_pack_options() -> void:
	"""Show 4 random options from the UPG pack - can use immediately or store as consumable."""
	var main_vbox = _create_popup("UPGRADE PACK")

	var desc_label = Label.new()
	desc_label.text = "Choose 1 of 4 options"
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(desc_label)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(grid)

	# Large pool of options - randomly pick 5 each time (roguelike variety)
	var all_options = [
		"heal", "energy", "damage", "block", "draw", "gold",
		"upgrade_card", "remove_card",
		"max_hp", "bonus_damage", "bonus_block", "weaken_enemy",
		"relic"  # Added relic option
	]
	_seeded_shuffle(all_options)

	for i in range(5):  # Increased from 4 to 5 options
		var option_type = all_options[i]
		var option_item = _create_upg_pack_option(option_type, i)
		grid.add_child(option_item)

	_add_close_button(main_vbox, "Skip")

func _create_upg_pack_option(option_type: String, index: int) -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 4)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(130, 70)

	var option_data = _get_option_data(option_type)
	var border_color = option_data.color

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.16)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color * 0.8
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 6
	vbox.offset_right = -6
	vbox.offset_top = 6
	vbox.offset_bottom = -6
	vbox.add_theme_constant_override("separation", 4)

	var name_label = Label.new()
	name_label.text = option_data.name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", border_color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = option_data.desc
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	panel.add_child(vbox)
	container.add_child(panel)

	# Buttons
	var btn_container = HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 4)
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(btn_container)

	# Use Now button
	var use_btn = Button.new()
	use_btn.text = "Use"
	use_btn.custom_minimum_size = Vector2(55, 28)
	use_btn.add_theme_font_size_override("font_size", 11)
	use_btn.pressed.connect(_use_upg_pack_option.bind(option_type, option_data))
	_apply_button_style(use_btn, border_color * 0.7, Color(0.15, 0.12, 0.18))
	btn_container.add_child(use_btn)

	# Store button (only for storable options)
	if option_data.storable and RunManager.has_empty_consumable_slot():
		var store_btn = Button.new()
		store_btn.text = "Store"
		store_btn.custom_minimum_size = Vector2(55, 28)
		store_btn.add_theme_font_size_override("font_size", 11)
		store_btn.pressed.connect(_store_upg_pack_option.bind(option_type, option_data))
		_apply_button_style(store_btn, COLOR_MINT * 0.7, Color(0.12, 0.18, 0.14))
		btn_container.add_child(store_btn)

	return container

func _get_option_data(option_type: String) -> Dictionary:
	match option_type:
		"heal":
			return {"name": "Health Potion", "desc": "Heal 25 HP", "color": COLOR_SOFT_GREEN, "storable": true, "value": 25}
		"energy":
			return {"name": "Energy Drink", "desc": "+2 Energy", "color": COLOR_SKY_BLUE, "storable": true, "value": 2}
		"damage":
			return {"name": "Bomb", "desc": "15 Damage", "color": COLOR_CORAL, "storable": true, "value": 15}
		"block":
			return {"name": "Shield Scroll", "desc": "+12 Block", "color": COLOR_LAVENDER, "storable": true, "value": 12}
		"draw":
			return {"name": "Wisdom Scroll", "desc": "Draw 3 cards", "color": COLOR_WARM_GOLD, "storable": true, "value": 3}
		"gold":
			return {"name": "Lucky Coin", "desc": "+30 Gold", "color": COLOR_WARM_GOLD, "storable": true, "value": 30}
		"upgrade_card":
			return {"name": "Upgrade", "desc": "Upgrade a card", "color": COLOR_MINT, "storable": false, "value": 0}
		"remove_card":
			return {"name": "Remove Card", "desc": "Remove a card", "color": COLOR_CORAL, "storable": false, "value": 0}
		"max_hp":
			return {"name": "Vitality Orb", "desc": "+8 Max HP", "color": COLOR_PEACH, "storable": false, "value": 8}
		"bonus_damage":
			return {"name": "Sharp Blade", "desc": "+2 Attack dmg", "color": COLOR_CORAL, "storable": false, "value": 2}
		"bonus_block":
			return {"name": "Iron Shield", "desc": "+2 Block", "color": COLOR_SKY_BLUE, "storable": false, "value": 2}
		"weaken_enemy":
			return {"name": "Curse Scroll", "desc": "Weaken next enemy", "color": COLOR_LAVENDER, "storable": true, "value": 2}
		"relic":
			return {"name": "Mystery Relic", "desc": "Get a random relic", "color": Color(1.0, 0.6, 0.2), "storable": false, "value": 0}
	return {"name": "Unknown", "desc": "", "color": Color.WHITE, "storable": false, "value": 0}

func _use_upg_pack_option(option_type: String, option_data: Dictionary) -> void:
	AudioManager.play_purchase()
	match option_type:
		"heal":
			RunManager.heal(option_data.value)
			_show_toast("Healed %d HP!" % option_data.value, COLOR_SOFT_GREEN)
		"energy":
			# Energy is for combat - show as immediate bonus next combat
			RunManager.bonus_energy += 1  # Temporary for this run
			_show_toast("+1 Bonus Energy!", COLOR_SKY_BLUE)
		"damage":
			# Can't use damage outside combat - convert to gold
			RunManager.run_gold += 15
			_show_toast("+15 Gold (no combat)!", COLOR_WARM_GOLD)
		"block":
			# Can't use block outside combat - convert to max HP
			RunManager.run_max_hp += 5
			RunManager.run_hp += 5
			_show_toast("+5 Max HP!", COLOR_LAVENDER)
		"draw":
			RunManager.bonus_draw += 1
			_show_toast("+1 Bonus Draw!", COLOR_WARM_GOLD)
		"gold":
			RunManager.run_gold += option_data.value
			_show_toast("+%d Gold!" % option_data.value, COLOR_WARM_GOLD)
		"upgrade_card":
			_close_popup()
			_show_upgrade_card_popup_direct()
			return
		"remove_card":
			_close_popup()
			_show_remove_card_popup_direct()
			return
		"max_hp":
			RunManager.run_max_hp += option_data.value
			RunManager.run_hp += option_data.value
			_show_toast("+%d Max HP!" % option_data.value, COLOR_PEACH)
		"bonus_damage":
			RunManager.bonus_damage += option_data.value
			_show_toast("+%d Attack Damage!" % option_data.value, COLOR_CORAL)
		"bonus_block":
			RunManager.bonus_block += option_data.value
			_show_toast("+%d Block!" % option_data.value, COLOR_SKY_BLUE)
		"weaken_enemy":
			RunManager.next_enemy_weakened += option_data.value
			_show_toast("Next enemy weakened!", COLOR_LAVENDER)
		"relic":
			# Don't call _close_popup() - _show_relic_popup() -> _create_popup() handles it
			if popup_panel:
				popup_panel.queue_free()
				popup_panel = null
			_show_relic_popup()
			return
	_close_popup()
	_update_ui()

func _store_upg_pack_option(option_type: String, option_data: Dictionary) -> void:
	# Create a consumable and store it
	var consumable = ConsumableData.new()
	consumable.consumable_name = option_data.name
	consumable.description = option_data.desc
	consumable.effect_value = option_data.value

	match option_type:
		"heal":
			consumable.effect_type = ConsumableData.ConsumableEffect.HEAL
		"energy":
			consumable.effect_type = ConsumableData.ConsumableEffect.ENERGY
		"damage":
			consumable.effect_type = ConsumableData.ConsumableEffect.DAMAGE
		"block":
			consumable.effect_type = ConsumableData.ConsumableEffect.BLOCK
		"draw":
			consumable.effect_type = ConsumableData.ConsumableEffect.DRAW
		"gold":
			consumable.effect_type = ConsumableData.ConsumableEffect.GOLD
		"weaken_enemy":
			consumable.effect_type = ConsumableData.ConsumableEffect.WEAKEN

	if RunManager.add_consumable(consumable):
		AudioManager.play_purchase()
		_show_toast("%s stored!" % option_data.name, COLOR_MINT)
	else:
		_show_toast("No room!", COLOR_CORAL)

	_close_popup()
	_update_ui()

func _show_free_card_upgrade_popup() -> void:
	"""Show card upgrade popup (costs gold, scales with stage)."""
	var upgradeable = RunManager.get_upgradeable_cards()
	if upgradeable.size() == 0:
		_show_toast("No cards to upgrade!", COLOR_CORAL)
		return

	var cost = _get_upgrade_card_cost()
	if not RunManager.spend_gold(cost):
		_show_toast("Not enough gold!", COLOR_CORAL)
		return

	AudioManager.play_purchase()
	_show_upgrade_card_popup_direct()

func _show_upgrade_card_popup_direct() -> void:
	"""Show upgrade card popup without charging gold (already paid via pack)."""
	var upgradeable = RunManager.get_upgradeable_cards()
	if upgradeable.size() == 0:
		_show_toast("No cards to upgrade!", COLOR_CORAL)
		return

	var main_vbox = _create_popup("UPGRADE A CARD")

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var center = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	center.add_child(grid)

	for i in range(RunManager.run_deck.size()):
		var card = RunManager.run_deck[i]
		var card_item = _create_deck_card_item(card, i, false, true)
		grid.add_child(card_item)

	_add_close_button(main_vbox)

func _show_remove_card_popup_direct() -> void:
	"""Show remove card popup without charging gold (already paid via pack)."""
	if RunManager.run_deck.size() <= 5:
		_show_toast("Not enough cards!", COLOR_CORAL)
		return

	var main_vbox = _create_popup("REMOVE A CARD")

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var center = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	center.add_child(grid)

	for i in range(RunManager.run_deck.size()):
		var card = RunManager.run_deck[i]
		var card_item = _create_deck_card_item(card, i, true, false)
		grid.add_child(card_item)

	_add_close_button(main_vbox)

func _on_card_pack_pressed() -> void:
	var cost = _get_card_pack_cost()
	if RunManager.run_gold < cost:
		return

	_show_card_pack_popup(cost)

func _on_continue() -> void:
	AudioManager.play_card_pickup()

	# Simple fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(left_panel, "modulate:a", 0.0, 0.25)
	tween.tween_property(right_panel, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(func(): RunManager.complete_encounter(true, RunManager.run_hp, 0))

func _on_menu() -> void:
	VFXManager.transition_to_scene("res://scenes/ui/main_menu.tscn")

# ============ POPUP HELPERS ============

func _create_popup(title: String) -> VBoxContainer:
	if popup_panel:
		popup_panel.queue_free()

	popup_panel = Panel.new()
	popup_panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.1, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_LAVENDER * 0.5
	popup_panel.add_theme_stylebox_override("panel", style)
	add_child(popup_panel)

	# Animate popup entrance
	popup_panel.modulate.a = 0
	popup_panel.scale = Vector2(0.95, 0.95)
	popup_panel.pivot_offset = popup_panel.size / 2

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(popup_panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(popup_panel, "scale", Vector2(1, 1), 0.3)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 16
	main_vbox.offset_right = -16
	main_vbox.offset_top = 16
	main_vbox.offset_bottom = -16
	main_vbox.add_theme_constant_override("separation", 10)
	popup_panel.add_child(main_vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", COLOR_WARM_GOLD)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title_label)

	return main_vbox

func _add_close_button(container: VBoxContainer, text: String = "Cancel") -> void:
	var close_btn = Button.new()
	close_btn.text = text
	close_btn.custom_minimum_size = Vector2(0, 44)
	close_btn.pressed.connect(_close_popup)
	_apply_button_style(close_btn, COLOR_CORAL * 0.8, Color(0.2, 0.1, 0.1))
	container.add_child(close_btn)

func _close_popup() -> void:
	if popup_panel:
		var tween = create_tween()
		tween.tween_property(popup_panel, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func():
			if popup_panel:
				popup_panel.queue_free()
				popup_panel = null
		)

# ============ UPGRADE POPUP (Stat Upgrades) ============

func _show_upgrade_popup() -> void:
	var main_vbox = _create_popup("UPGRADES")

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	for upgrade in UPGRADES:
		var cost = int(upgrade.cost * (1.0 + (RunManager.current_stage - 1) * 0.05))
		var item = _create_upgrade_item(upgrade, cost)
		grid.add_child(item)

	_add_close_button(main_vbox, "Close")

func _create_upgrade_item(upgrade: Dictionary, cost: int) -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 3)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 50)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.15)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = upgrade.color * 0.8
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 5
	vbox.offset_right = -5
	vbox.offset_top = 4
	vbox.offset_bottom = -4

	var name_label = Label.new()
	name_label.text = upgrade.name
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", upgrade.color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = upgrade.desc
	desc_label.add_theme_font_size_override("font_size", 9)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	panel.add_child(vbox)
	container.add_child(panel)

	var buy_btn = Button.new()
	buy_btn.text = "%d G" % cost
	buy_btn.custom_minimum_size = Vector2(0, 28)
	buy_btn.disabled = RunManager.run_gold < cost
	buy_btn.pressed.connect(_on_buy_upgrade.bind(upgrade, cost))
	_apply_button_style(buy_btn, upgrade.color * 0.7, Color(0.15, 0.12, 0.18))
	container.add_child(buy_btn)

	return container

func _on_buy_upgrade(upgrade: Dictionary, cost: int) -> void:
	if RunManager.spend_gold(cost):
		AudioManager.play_purchase()
		RunManager.add_upgrade(upgrade.id, upgrade.value)
		VFXManager.gold_effect(self, Vector2(size.x / 2, size.y / 2), cost)
		_show_toast(upgrade.name + " acquired!", upgrade.color)
		_close_popup()
		_update_ui()

# ============ REMOVE CARD POPUP (From Upg Pack) ============

func _show_remove_card_popup() -> void:
	"""Legacy function - now handled by _show_remove_card_popup_direct."""
	_show_remove_card_popup_direct()
	return

func _show_remove_card_popup_legacy() -> void:
	if RunManager.run_deck.size() <= 5:
		_show_toast("Not enough cards!", COLOR_CORAL)
		return

	if not RunManager.spend_gold(_get_upg_pack_cost()):
		return

	AudioManager.play_purchase()

	var main_vbox = _create_popup("REMOVE A CARD")

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var center = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	center.add_child(grid)

	for i in range(RunManager.run_deck.size()):
		var card = RunManager.run_deck[i]
		var card_item = _create_deck_card_item(card, i, true, false)
		grid.add_child(card_item)

	_add_close_button(main_vbox)

# ============ UPGRADE CARD POPUP (From Upg Pack) ============

func _show_upgrade_card_popup() -> void:
	"""Legacy function - now handled by _show_upgrade_card_popup_direct."""
	_show_upgrade_card_popup_direct()
	return

func _show_upgrade_card_popup_legacy() -> void:
	var upgradeable = RunManager.get_upgradeable_cards()
	if upgradeable.size() == 0:
		_show_toast("No cards to upgrade!", COLOR_CORAL)
		return

	if not RunManager.spend_gold(_get_upg_pack_cost()):
		return

	AudioManager.play_purchase()

	var main_vbox = _create_popup("UPGRADE A CARD")

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var center = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)

	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	center.add_child(grid)

	for i in range(RunManager.run_deck.size()):
		var card = RunManager.run_deck[i]
		var card_item = _create_deck_card_item(card, i, false, true)
		grid.add_child(card_item)

	_add_close_button(main_vbox)

# ============ RELIC POPUP (From Upg Pack) ============

func _show_relic_popup() -> void:
	"""Legacy relic popup - not used in new UPG pack system."""
	var relic = RunManager.get_random_relic(true)
	if not relic:
		_show_toast("No relics available!", COLOR_CORAL)
		return

	# Note: Gold is no longer spent here - UPG pack now shows 4 options

	var main_vbox = _create_popup("RELIC FOUND!")

	var relic_panel = Panel.new()
	relic_panel.custom_minimum_size = Vector2(180, 100)
	relic_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = relic.get_rarity_color()
	style.shadow_color = Color(relic.get_rarity_color().r, relic.get_rarity_color().g, relic.get_rarity_color().b, 0.3)
	style.shadow_size = 4
	relic_panel.add_theme_stylebox_override("panel", style)
	main_vbox.add_child(relic_panel)

	var relic_vbox = VBoxContainer.new()
	relic_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	relic_vbox.offset_left = 8
	relic_vbox.offset_right = -8
	relic_vbox.offset_top = 8
	relic_vbox.offset_bottom = -8
	relic_vbox.add_theme_constant_override("separation", 6)
	relic_panel.add_child(relic_vbox)

	var name_label = Label.new()
	name_label.text = relic.relic_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", relic.get_rarity_color())
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic_vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = relic.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	relic_vbox.add_child(desc_label)

	var take_btn = Button.new()
	take_btn.text = "Take Relic"
	take_btn.custom_minimum_size = Vector2(0, 44)
	take_btn.pressed.connect(_on_take_relic.bind(relic))
	_apply_button_style(take_btn, relic.get_rarity_color(), Color(0.18, 0.15, 0.22))
	main_vbox.add_child(take_btn)

	_add_close_button(main_vbox, "Skip")

func _on_take_relic(relic: RelicData) -> void:
	RunManager.add_relic(relic)
	_show_toast(relic.relic_name + " acquired!", relic.get_rarity_color())
	_close_popup()
	_update_ui()

# ============ CARD PACK POPUP ============

func _show_card_pack_popup(cost: int = 50) -> void:
	if not RunManager.spend_gold(cost):
		return

	AudioManager.play_purchase()

	var main_vbox = _create_popup("PICK A CARD")

	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 12)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(hbox)

	# Generate 4 random cards (increased from 3)
	var available_cards = ALL_CARDS.duplicate()
	_seeded_shuffle(available_cards)

	for i in range(4):
		var card = available_cards[i].duplicate()
		var card_item = _create_pack_card_item(card)
		hbox.add_child(card_item)

	_add_close_button(main_vbox, "Skip")

func _create_pack_card_item(card: CardData) -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 6)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(85, 90)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.16)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	var border_color = COLOR_LAVENDER
	match card.card_type:
		CardData.CardType.ATTACK:
			border_color = COLOR_CORAL
		CardData.CardType.DEFEND:
			border_color = COLOR_SKY_BLUE
		CardData.CardType.SKILL:
			border_color = COLOR_MINT
	style.border_color = border_color * 0.8
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 5
	vbox.offset_right = -5
	vbox.offset_top = 5
	vbox.offset_bottom = -5
	vbox.add_theme_constant_override("separation", 3)

	var name_label = Label.new()
	name_label.text = card.card_name
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", border_color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var cost_label = Label.new()
	cost_label.text = "%d Energy" % card.energy_cost
	cost_label.add_theme_font_size_override("font_size", 9)
	cost_label.add_theme_color_override("font_color", COLOR_SKY_BLUE * 0.9)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cost_label)

	var desc_label = Label.new()
	desc_label.text = card.description
	desc_label.add_theme_font_size_override("font_size", 8)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	panel.add_child(vbox)
	container.add_child(panel)

	var pick_btn = Button.new()
	pick_btn.text = "Pick"
	pick_btn.custom_minimum_size = Vector2(0, 32)
	pick_btn.pressed.connect(_on_pick_card.bind(card))
	_apply_button_style(pick_btn, border_color * 0.7, Color(0.15, 0.12, 0.18))
	container.add_child(pick_btn)

	return container

func _on_pick_card(card: CardData) -> void:
	RunManager.add_card_to_deck(card.duplicate())
	_show_toast(card.card_name + " added!", COLOR_MINT)
	_close_popup()
	_update_ui()

# ============ DECK CARD ITEM (for Remove/Upgrade) ============

func _create_deck_card_item(card: CardData, index: int, remove_mode: bool, upgrade_mode: bool) -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 4)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(80, 60)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.16)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	var border_color = COLOR_LAVENDER
	match card.card_type:
		CardData.CardType.ATTACK:
			border_color = COLOR_CORAL
		CardData.CardType.DEFEND:
			border_color = COLOR_SKY_BLUE
		CardData.CardType.SKILL:
			border_color = COLOR_MINT
	style.border_color = border_color * 0.7
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 4
	vbox.offset_right = -4
	vbox.offset_top = 4
	vbox.offset_bottom = -4

	var name_label = Label.new()
	name_label.text = card.get_display_name() if card.has_method("get_display_name") else card.card_name
	name_label.add_theme_font_size_override("font_size", 10)
	if card.is_upgraded:
		name_label.add_theme_color_override("font_color", COLOR_MINT)
	else:
		name_label.add_theme_color_override("font_color", border_color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var cost_label = Label.new()
	cost_label.text = "%d E" % (card.get_effective_cost() if card.has_method("get_effective_cost") else card.energy_cost)
	cost_label.add_theme_font_size_override("font_size", 9)
	cost_label.add_theme_color_override("font_color", COLOR_SKY_BLUE * 0.8)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cost_label)

	panel.add_child(vbox)
	container.add_child(panel)

	if remove_mode:
		var remove_btn = Button.new()
		remove_btn.text = "Remove"
		remove_btn.custom_minimum_size = Vector2(0, 26)
		remove_btn.pressed.connect(_on_remove_card.bind(index))
		_apply_button_style(remove_btn, COLOR_CORAL * 0.8, Color(0.2, 0.1, 0.1))
		container.add_child(remove_btn)

	if upgrade_mode:
		var upgrade_btn = Button.new()
		if card.is_upgraded:
			upgrade_btn.text = "Max"
			upgrade_btn.disabled = true
		else:
			upgrade_btn.text = "Upgrade"
		upgrade_btn.custom_minimum_size = Vector2(0, 26)
		upgrade_btn.pressed.connect(_on_upgrade_card.bind(index))
		_apply_button_style(upgrade_btn, COLOR_MINT * 0.8, Color(0.1, 0.18, 0.12))
		container.add_child(upgrade_btn)

	return container

func _on_remove_card(index: int) -> void:
	RunManager.remove_card_from_deck(index)
	_show_toast("Card removed!", COLOR_CORAL)
	_close_popup()
	_update_ui()

func _on_upgrade_card(index: int) -> void:
	if RunManager.upgrade_card(index):
		var card = RunManager.run_deck[index]
		_show_toast(card.get_display_name() + " upgraded!", COLOR_MINT)
	_close_popup()
	_update_ui()

# ============ TOAST ============

func _seeded_shuffle(arr: Array) -> void:
	"""Fisher-Yates shuffle using seeded RNG for deterministic results."""
	for i in range(arr.size() - 1, 0, -1):
		var j = RunManager.seeded_randi_range(0, i)
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp

func _show_toast(text: String, color: Color = COLOR_WARM_GOLD) -> void:
	var toast = Label.new()
	toast.text = text
	toast.add_theme_font_size_override("font_size", 16)
	toast.add_theme_color_override("font_color", color)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.set_anchors_preset(Control.PRESET_CENTER)
	toast.position = Vector2(-70, -40)
	toast.scale = Vector2(0.8, 0.8)
	add_child(toast)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(toast, "position:y", toast.position.y - 50, 0.8)
	tween.tween_property(toast, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(toast, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(toast.queue_free)
