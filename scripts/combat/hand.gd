extends Control
class_name Hand

signal card_played(card_data: CardData)
signal selection_changed(selected_cards: Array[Card])
signal play_hand_requested(selected_cards: Array[Card])

const CARD_SCENE = preload("res://scenes/cards/card.tscn")
const CARD_WIDTH = 110
const CARD_SPACING = -20  # Negative for overlap
const MAX_FAN_ANGLE = 25.0  # Maximum rotation in degrees
const CARD_HOVER_HEIGHT = 30
const MAX_SELECTED_CARDS = 3  # For Pick-3-Cards mechanic

var cards: Array[Card] = []
var selected_cards: Array[Card] = []

func add_card(card_data: CardData) -> void:
	var card_instance = CARD_SCENE.instantiate() as Card
	add_child(card_instance)
	card_instance.setup_card(card_data)
	card_instance.card_played.connect(_on_card_played)
	card_instance.card_selected.connect(_on_card_selected)
	card_instance.card_deselected.connect(_on_card_deselected)
	cards.append(card_instance)

	# Animate card draw
	card_instance.modulate.a = 0
	card_instance.scale = Vector2(0.5, 0.5)
	card_instance.position = Vector2(size.x / 2, -100)

	await get_tree().process_frame
	_arrange_cards_animated()

func remove_card(card: Card) -> void:
	# Remove from selection if selected
	if card in selected_cards:
		selected_cards.erase(card)
		selection_changed.emit(selected_cards)
	cards.erase(card)
	card.queue_free()
	_arrange_cards_animated()

func clear_hand() -> void:
	selected_cards.clear()
	for card in cards:
		card.queue_free()
	cards.clear()
	selection_changed.emit(selected_cards)

func update_playable_cards(current_energy: int) -> void:
	for card in cards:
		card.set_playable(card.card_data.get_effective_cost() <= current_energy)

func _arrange_cards_animated() -> void:
	var card_count = cards.size()
	if card_count == 0:
		return

	# Calculate fan parameters
	var total_width = card_count * CARD_WIDTH + (card_count - 1) * CARD_SPACING
	var start_x = (size.x - total_width) / 2

	# Calculate rotation per card
	var angle_step = 0.0
	if card_count > 1:
		angle_step = min(MAX_FAN_ANGLE * 2 / (card_count - 1), 8.0)

	for i in range(card_count):
		var card = cards[i]
		card.original_index = i

		# Calculate position
		var target_x = start_x + i * (CARD_WIDTH + CARD_SPACING)

		# Calculate rotation (fan out from center)
		var center_offset = i - (card_count - 1) / 2.0
		var target_rotation = deg_to_rad(center_offset * angle_step)

		# Calculate Y offset for arc effect
		var arc_offset = abs(center_offset) * 5.0

		var target_pos = Vector2(target_x, arc_offset + 10)

		card.original_rotation = target_rotation
		card.hand_position = card.global_position + target_pos - card.position

		# Animate to position
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "position", target_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "rotation", target_rotation, 0.3).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "modulate:a", 1.0, 0.2)
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT)

		card.z_index = i

func _on_card_played(card: Card) -> void:
	card_played.emit(card.card_data)
	remove_card(card)

func _on_card_selected(card: Card) -> void:
	if selected_cards.size() >= MAX_SELECTED_CARDS:
		# Deselect the first selected card to make room
		if selected_cards.size() > 0:
			selected_cards[0].deselect()
	selected_cards.append(card)
	selection_changed.emit(selected_cards)

func _on_card_deselected(card: Card) -> void:
	selected_cards.erase(card)
	selection_changed.emit(selected_cards)

func get_selected_cards() -> Array[Card]:
	return selected_cards

func get_selected_card_data() -> Array[CardData]:
	var data: Array[CardData] = []
	for card in selected_cards:
		data.append(card.card_data)
	return data

func get_total_selected_cost() -> int:
	var total = 0
	for card in selected_cards:
		total += card.card_data.get_effective_cost()
	return total

func clear_selection() -> void:
	for card in selected_cards.duplicate():
		card.deselect()
	selected_cards.clear()
	selection_changed.emit(selected_cards)

func play_selected_cards() -> void:
	if selected_cards.is_empty():
		return

	# Store cards to play before clearing selection
	var cards_to_play = selected_cards.duplicate()
	selected_cards.clear()

	# Play each card with staggered animation
	for i in range(cards_to_play.size()):
		var card = cards_to_play[i]
		await get_tree().create_timer(0.05 * i).timeout
		card.play_card_animation()

func get_card_count() -> int:
	return cards.size()

func get_selected_count() -> int:
	return selected_cards.size()
