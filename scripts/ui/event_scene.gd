extends Control

var current_event: Dictionary = {}
var choice_buttons: Array[Button] = []

@onready var title_label = $SafeArea/VBox/TitleLabel
@onready var description_label = $SafeArea/VBox/EventPanel/Margin/DescriptionLabel
@onready var choices_container = $SafeArea/VBox/ChoicesContainer
@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/VBox/ResultLabel
@onready var continue_button = $ResultPanel/VBox/ContinueButton

func _ready() -> void:
	result_panel.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	Localization.locale_changed.connect(_on_locale_changed)
	_generate_event()
	_animate_entrance()

func _on_locale_changed(_new_locale: String) -> void:
	continue_button.text = Localization.t("EVENT_CONTINUE")

func _animate_entrance() -> void:
	# Fade in title
	title_label.modulate.a = 0
	description_label.modulate.a = 0

	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.4)
	tween.tween_property(description_label, "modulate:a", 1.0, 0.5)

	# Animate buttons sequentially
	await get_tree().create_timer(0.3).timeout
	for i in range(choice_buttons.size()):
		var btn = choice_buttons[i]
		btn.modulate.a = 0
		btn.scale = Vector2(0.9, 0.9)
		btn.pivot_offset = btn.size / 2

		var btn_tween = create_tween()
		btn_tween.set_parallel(true)
		btn_tween.tween_property(btn, "modulate:a", 1.0, 0.3).set_delay(i * 0.1)
		btn_tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.3).set_delay(i * 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _generate_event() -> void:
	current_event = EventData.create_random_event()
	title_label.text = current_event.name
	description_label.text = current_event.description

	# Clear and create choice buttons
	for child in choices_container.get_children():
		child.queue_free()
	choice_buttons.clear()

	for i in range(current_event.choices.size()):
		var choice = current_event.choices[i]
		var button = Button.new()
		button.text = choice.text
		button.custom_minimum_size = Vector2(0, 55)
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_on_choice_selected.bind(i))

		# Style the button based on choice type
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2

		# Color based on whether it has effects (or is a "leave" option)
		if choice.effects.size() == 0:
			style.bg_color = Color(0.15, 0.15, 0.18, 0.9)
			style.border_color = Color(0.4, 0.4, 0.45)
		else:
			style.bg_color = Color(0.12, 0.15, 0.2, 0.9)
			style.border_color = Color(0.4, 0.6, 0.8)

		button.add_theme_stylebox_override("normal", style)

		# Add hover effect
		button.mouse_entered.connect(_on_button_hover.bind(button, true))
		button.mouse_exited.connect(_on_button_hover.bind(button, false))

		choices_container.add_child(button)
		choice_buttons.append(button)

func _on_button_hover(button: Button, is_hovering: bool) -> void:
	var tween = create_tween()
	if is_hovering:
		tween.tween_property(button, "scale", Vector2(1.03, 1.03), 0.1).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_OUT)

func _on_choice_selected(choice_index: int) -> void:
	AudioManager.play_card_pickup()

	var choice = current_event.choices[choice_index]
	var effects = choice.get("effects", [])
	var result_text = ""
	var center = size / 2

	for effect in effects:
		match effect.type:
			"heal":
				RunManager.heal(effect.value)
				result_text += "Healed %d HP\n" % effect.value
				VFXManager.heal_effect(self, center, effect.value)
			"damage":
				RunManager.run_hp -= effect.value
				result_text += "Lost %d HP\n" % effect.value
				VFXManager.damage_effect(self, center, effect.value)
			"gold":
				if effect.value > 0:
					RunManager.run_gold += effect.value
					result_text += "Gained %d Gold\n" % effect.value
					VFXManager.gold_effect(self, center, effect.value)
				else:
					if RunManager.run_gold >= abs(effect.value):
						RunManager.run_gold += effect.value  # Negative value
						result_text += "Spent %d Gold\n" % abs(effect.value)
					else:
						result_text += "Not enough Gold!\n"
						continue
			"max_hp":
				RunManager.run_max_hp += effect.value
				RunManager.run_hp += effect.value
				result_text += "Max HP increased by %d\n" % effect.value
				VFXManager.heal_effect(self, center, effect.value)
			"relic":
				var relic = RunManager.get_random_relic()
				if relic:
					RunManager.add_relic(relic)
					result_text += "Obtained: %s\n" % relic.relic_name
					VFXManager.spawn_glow(self, center, Color(0.8, 0.4, 1), 120)
				else:
					result_text += "No relics available\n"
			"upgrade_random":
				var upgradeable = RunManager.get_upgradeable_cards()
				if upgradeable.size() > 0:
					var random_index = upgradeable[randi() % upgradeable.size()]
					RunManager.upgrade_card(random_index)
					var card = RunManager.run_deck[random_index]
					result_text += "Upgraded: %s\n" % card.get_display_name()
					VFXManager.spawn_glow(self, center, Color(0.4, 1, 0.5), 100)
				else:
					result_text += "No cards to upgrade\n"
			"bouquet":
				RunManager.add_bouquets(effect.value)
				GameManager.add_bouquets(effect.value)
				result_text += "Obtained %d Bouquet(s)\n" % effect.value
				VFXManager.spawn_particles(self, center, Color(1, 0.7, 0.8), 15)
			"gamble":
				if randf() < 0.7:  # 70% success
					RunManager.run_gold += effect.success_value
					result_text += "Success! Gained %d Gold\n" % effect.success_value
					VFXManager.gold_effect(self, center, effect.success_value)
				else:
					RunManager.run_hp -= abs(effect.fail_value)
					result_text += "Trap! Lost %d HP\n" % abs(effect.fail_value)
					VFXManager.damage_effect(self, center, abs(effect.fail_value))

	if result_text == "":
		result_text = "You continue on your journey."

	# Check if player died
	if RunManager.run_hp <= 0:
		RunManager.complete_encounter(false, 0, 0)
		return

	# Animate out choices
	for i in range(choice_buttons.size()):
		var btn = choice_buttons[i]
		var tween = create_tween()
		tween.tween_property(btn, "modulate:a", 0.0, 0.2).set_delay(i * 0.05)

	await get_tree().create_timer(0.3).timeout

	# Show result with animation
	result_label.text = result_text.strip_edges()
	result_panel.visible = true
	result_panel.modulate.a = 0
	result_panel.scale = Vector2(0.9, 0.9)
	result_panel.pivot_offset = result_panel.size / 2

	var result_tween = create_tween()
	result_tween.set_parallel(true)
	result_tween.tween_property(result_panel, "modulate:a", 1.0, 0.3)
	result_tween.tween_property(result_panel, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Hide choices
	for child in choices_container.get_children():
		child.visible = false

func _on_continue_pressed() -> void:
	RunManager.complete_encounter(true, RunManager.run_hp, 0)
