extends Control
class_name Card

signal card_played(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)
signal card_selected(card: Card)
signal card_deselected(card: Card)

@export var card_data: CardData

var is_playable: bool = true
var is_dragging: bool = false
var is_hovered: bool = false
var is_selected: bool = false  # For Balatro-style selection
var original_position: Vector2
var original_rotation: float = 0.0
var original_index: int = 0
var hand_position: Vector2  # Position in hand
var selected_position_offset: float = -50.0  # How much cards raise when selected

# Visual nodes
var background: Panel
var glow: Panel
var cost_circle: Panel
var cost_label: Label
var name_label: Label
var description_label: Label
var type_label: Label
var card_border: Panel
var upgrade_badge: Panel

# Colors for card types
const TYPE_COLORS = {
	"attack": Color(0.85, 0.25, 0.25),    # Red
	"defend": Color(0.25, 0.45, 0.85),    # Blue
	"skill": Color(0.25, 0.75, 0.35),     # Green
	"power": Color(0.75, 0.55, 0.25)      # Gold
}

func _ready() -> void:
	_setup_card_visuals()
	_apply_card_scale()

	if card_data:
		_apply_card_visuals()

func _apply_card_scale() -> void:
	# Apply card size setting from StatsManager
	var card_scale = StatsManager.card_size
	scale = Vector2(card_scale, card_scale)
	# Adjust pivot for proper scaling
	pivot_offset = size / 2

func _setup_card_visuals() -> void:
	# Main background
	background = $Background
	glow = $Glow
	cost_circle = $CostCircle
	cost_label = $CostCircle/CostLabel
	name_label = $Content/NameLabel
	description_label = $Content/DescriptionLabel
	type_label = $Content/TypeLabel
	card_border = $CardBorder
	upgrade_badge = $UpgradeBadge if has_node("UpgradeBadge") else null

func setup_card(data: CardData) -> void:
	card_data = data
	if is_node_ready():
		_apply_card_visuals()

func _apply_card_visuals() -> void:
	if not card_data:
		return

	# Use translated name if available, with upgrade indicator
	var display_name = Localization.card_name(card_data.card_name)
	if card_data.is_upgraded:
		display_name += "+"
	name_label.text = display_name

	cost_label.text = str(card_data.get_effective_cost())

	# Use translated description if available
	var translated_desc = Localization.card_desc(card_data.card_name)
	if translated_desc != "":
		description_label.text = _get_upgraded_translated_desc(translated_desc)
	else:
		description_label.text = card_data.get_upgraded_description()

	# Show/hide upgrade badge
	if upgrade_badge:
		upgrade_badge.visible = card_data.is_upgraded

	var type_color: Color
	match card_data.card_type:
		CardData.CardType.ATTACK:
			type_label.text = Localization.t("CARD_ATTACK")
			type_color = TYPE_COLORS["attack"]
		CardData.CardType.DEFEND:
			type_label.text = Localization.t("CARD_DEFEND")
			type_color = TYPE_COLORS["defend"]
		CardData.CardType.SKILL:
			type_label.text = Localization.t("CARD_SKILL")
			type_color = TYPE_COLORS["skill"]
		CardData.CardType.POWER:
			type_label.text = Localization.t("CARD_POWER")
			type_color = TYPE_COLORS["power"]

	# High Contrast Mode - use brighter, more saturated colors
	if StatsManager.high_contrast:
		type_color = type_color.lightened(0.3)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		description_label.add_theme_color_override("font_color", Color.WHITE)
		type_label.add_theme_color_override("font_color", Color.WHITE)
		cost_label.add_theme_color_override("font_color", Color.WHITE)

	# Card Borders setting
	card_border.visible = StatsManager.show_card_borders

	# Apply type color to border and cost circle
	var border_style = card_border.get_theme_stylebox("panel").duplicate()
	if border_style is StyleBoxFlat:
		border_style.border_color = type_color
		if StatsManager.high_contrast:
			border_style.border_width_left = 4
			border_style.border_width_top = 4
			border_style.border_width_right = 4
			border_style.border_width_bottom = 4
		card_border.add_theme_stylebox_override("panel", border_style)

	var cost_style = cost_circle.get_theme_stylebox("panel").duplicate()
	if cost_style is StyleBoxFlat:
		cost_style.bg_color = type_color
		cost_circle.add_theme_stylebox_override("panel", cost_style)

	type_label.modulate = type_color if not StatsManager.high_contrast else Color.WHITE
	glow.modulate = type_color
	glow.modulate.a = 0

func _format_description() -> String:
	var desc = card_data.description
	# Highlight numbers in description
	return desc

func _get_upgraded_translated_desc(desc: String) -> String:
	# Replace base values with upgraded values in translated description
	if not card_data.is_upgraded:
		return desc
	if card_data.damage > 0:
		desc = desc.replace(str(card_data.damage), str(card_data.get_effective_damage()))
	if card_data.block > 0:
		desc = desc.replace(str(card_data.block), str(card_data.get_effective_block()))
	if card_data.draw_cards > 0:
		var old_draw = str(card_data.draw_cards)
		var new_draw = str(card_data.get_effective_draw())
		desc = desc.replace(old_draw + " ", new_draw + " ")  # "Draw 1 " -> "Draw 2 "
	return desc

func set_playable(can_play: bool) -> void:
	is_playable = can_play
	if can_play:
		modulate = Color.WHITE
		# Show glow
		var tween = create_tween()
		tween.tween_property(glow, "modulate:a", 0.4, 0.2)
	else:
		modulate = Color(0.6, 0.6, 0.6)
		glow.modulate.a = 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_playable:
				# Balatro-style: tap to select/deselect
				toggle_selection()

func toggle_selection() -> void:
	if is_selected:
		deselect()
	else:
		select()

func select() -> void:
	if is_selected or not is_playable:
		return
	is_selected = true
	z_index = 60

	# Animate card raising up
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + selected_position_offset, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0.0, 0.15)
	tween.tween_property(glow, "modulate:a", 0.8, 0.15)

	card_selected.emit(self)

func deselect() -> void:
	if not is_selected:
		return
	is_selected = false
	z_index = original_index

	# Animate card returning down
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - selected_position_offset, 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", original_rotation, 0.15)
	if is_playable:
		tween.tween_property(glow, "modulate:a", 0.4, 0.15)
	else:
		tween.tween_property(glow, "modulate:a", 0.0, 0.15)

	card_deselected.emit(self)

func play_card_animation(emit_signal: bool = true) -> void:
	# Animate card flying to enemy (called externally when playing hand)
	var target_pos = Vector2(get_viewport_rect().size.x / 2, 150)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_pos, 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)

	await tween.finished
	# Only emit signal if requested (false when using Play Hand button)
	if emit_signal:
		card_played.emit(self)

func _return_to_hand() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", hand_position, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", original_rotation, 0.2)

func _on_mouse_entered() -> void:
	if is_selected:
		return  # Don't change hover state if selected
	is_hovered = true
	card_hovered.emit(self)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 30, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.1)
	z_index = 50

func _on_mouse_exited() -> void:
	if is_selected:
		return  # Don't change state if selected
	is_hovered = false
	card_unhovered.emit(self)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(self, "position:y", hand_position.y - global_position.y + position.y + 30, 0.1)
	tween.tween_property(self, "rotation", original_rotation, 0.1)
	z_index = original_index
