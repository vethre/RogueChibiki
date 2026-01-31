extends Control

@onready var combat_manager: CombatManager = $CombatManager
@onready var hand: Hand = $Hand

# Player UI
@onready var player_portrait: TextureRect = $PlayerArea/Portrait
@onready var player_hp_bar: ProgressBar = $PlayerArea/HPContainer/HPBar
@onready var player_hp_label: Label = $PlayerArea/HPContainer/HPLabel
@onready var player_block_label: Label = $PlayerArea/BlockLabel

# Enemy UI
@onready var enemy_sprite: TextureRect = $EnemyArea/EnemySprite
@onready var enemy_hp_bar: ProgressBar = $EnemyArea/HPContainer/HPBar
@onready var enemy_hp_label: Label = $EnemyArea/HPContainer/HPLabel
@onready var enemy_block_label: Label = $EnemyArea/BlockLabel
@onready var enemy_intent_label: Label = $EnemyArea/IntentLabel

# Top bar
@onready var gold_label: Label = $TopBar/HBox/GoldContainer/GoldLabel
@onready var stage_label: Label = $TopBar/HBox/StageInfo/StageLabel
@onready var encounter_label: Label = $TopBar/HBox/StageInfo/EncounterLabel
@onready var score_label: Label = $TopBar/HBox/ScoreContainer/ScoreLabel

# Energy and Relics
@onready var energy_container: HBoxContainer = $EnergyPanel/EnergyContainer
@onready var relics_container: HBoxContainer = $RelicsPanel/RelicsContainer

# Consumables UI (created dynamically)
var consumables_panel: Panel = null
var consumables_container: HBoxContainer = null

# Deck info
@onready var draw_pile_label: Label = $DeckInfo/DrawPile/Label
@onready var discard_pile_label: Label = $DeckInfo/DiscardPile/Label

# Turn indicator
@onready var turn_label: Label = $TurnBanner/TurnLabel

# Buttons and overlays
@onready var end_turn_button: Button = $EndTurnButton
@onready var pause_menu_button: Button = $MenuButton
@onready var result_panel: Panel = $ResultPanel
@onready var result_label: Label = $ResultPanel/ResultLabel
@onready var result_gold_label: Label = $ResultPanel/GoldLabel
@onready var continue_button: Button = $ResultPanel/ContinueButton
@onready var menu_button: Button = $ResultPanel/MenuButton

# Play Hand button (Balatro-style)
var play_hand_button: Button = null
var selection_label: Label = null

# Pause panel
@onready var pause_panel: Panel = $PausePanel
@onready var pause_resume_btn: Button = $PausePanel/PauseVBox/ResumeButton
@onready var pause_settings_btn: Button = $PausePanel/PauseVBox/SettingsButton
@onready var pause_main_menu_btn: Button = $PausePanel/PauseVBox/MainMenuButton
@onready var pause_quit_btn: Button = $PausePanel/PauseVBox/QuitButton

# Debug panel
@onready var debug_button: Button = $DebugButton
@onready var debug_panel: Panel = $DebugPanel
@onready var debug_skip_btn: Button = $DebugPanel/DebugScroll/DebugVBox/SkipStageBtn
@onready var debug_gold_btn: Button = $DebugPanel/DebugScroll/DebugVBox/AddGoldBtn
@onready var debug_heal_btn: Button = $DebugPanel/DebugScroll/DebugVBox/HealPlayerBtn
@onready var debug_energy_btn: Button = $DebugPanel/DebugScroll/DebugVBox/AddEnergyBtn
@onready var debug_draw_btn: Button = $DebugPanel/DebugScroll/DebugVBox/DrawCardsBtn
@onready var debug_maxhp_btn: Button = $DebugPanel/DebugScroll/DebugVBox/AddMaxHPBtn
@onready var debug_godmode_btn: Button = $DebugPanel/DebugScroll/DebugVBox/GodModeBtn
@onready var debug_skipstage_btn: Button = $DebugPanel/DebugScroll/DebugVBox/SkipToStageBtn
@onready var debug_close_btn: Button = $DebugPanel/DebugScroll/DebugVBox/CloseDebugBtn

var god_mode_enabled: bool = false

# FX
@onready var damage_label: Label = $FXLayer/DamageLabel
@onready var effect_label: Label = $FXLayer/EffectLabel
@onready var out_of_cards_label: Label = $FXLayer/OutOfCardsLabel

# Relic info popup
@onready var relic_info_popup: Panel = $FXLayer/RelicInfoPopup
@onready var relic_name_label: Label = $FXLayer/RelicInfoPopup/VBox/RelicName
@onready var relic_desc_label: Label = $FXLayer/RelicInfoPopup/VBox/RelicDesc

# Enemy sprites
var enemy_sprites: Array[String] = [
	"res://assets/cmorphe.PNG",
	"res://assets/cyuuechka.PNG",
	"res://assets/morphilina.PNG",
	"res://assets/sasavot.PNG"
]
var enemy_names: Array[String] = ["Cmorphe", "Cyuuechka", "Morphilina", "Sasavot"]

var energy_orbs: Array[Control] = []
var energy_icon_texture: Texture2D
var gold_earned_this_combat: int = 0

var run_complete_panel: Panel = null

func _ready() -> void:
	combat_manager.player_stats_changed.connect(_update_player_ui)
	combat_manager.enemy_stats_changed.connect(_update_enemy_ui)
	combat_manager.turn_changed.connect(_on_turn_changed)
	combat_manager.combat_ended.connect(_on_combat_ended)
	combat_manager.damage_dealt.connect(_on_damage_dealt)
	combat_manager.block_gained.connect(_on_block_gained)
	combat_manager.card_effect_triggered.connect(_on_effect_triggered)
	combat_manager.gold_earned.connect(_on_gold_earned)
	combat_manager.hand_selection_changed.connect(_on_hand_selection_changed)

	RunManager.run_completed.connect(_on_run_completed)
	Localization.locale_changed.connect(_on_locale_changed)

	end_turn_button.pressed.connect(_on_end_turn_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	_setup_play_hand_button()

	# Pause menu connections
	pause_menu_button.pressed.connect(_on_pause_menu_pressed)
	pause_resume_btn.pressed.connect(_on_pause_resume_pressed)
	pause_settings_btn.pressed.connect(_on_pause_settings_pressed)
	pause_main_menu_btn.pressed.connect(_on_pause_main_menu_pressed)
	pause_quit_btn.pressed.connect(_on_pause_quit_pressed)

	# Debug button connections
	debug_button.pressed.connect(_on_debug_button_pressed)
	debug_skip_btn.pressed.connect(_on_debug_skip_pressed)
	debug_gold_btn.pressed.connect(_on_debug_gold_pressed)
	debug_heal_btn.pressed.connect(_on_debug_heal_pressed)
	debug_energy_btn.pressed.connect(_on_debug_energy_pressed)
	debug_draw_btn.pressed.connect(_on_debug_draw_pressed)
	debug_maxhp_btn.pressed.connect(_on_debug_maxhp_pressed)
	debug_godmode_btn.pressed.connect(_on_debug_godmode_pressed)
	debug_skipstage_btn.pressed.connect(_on_debug_skipstage_pressed)
	debug_close_btn.pressed.connect(_on_debug_close_pressed)

	result_panel.hide()
	pause_panel.hide()
	debug_panel.hide()
	_update_debug_button_visibility()
	damage_label.hide()
	effect_label.hide()
	relic_info_popup.hide()

	_setup_energy_orbs()
	_setup_consumables_panel()
	_update_relics_display()
	_update_consumables_display()
	_apply_localization()
	_start_combat()

	RunManager.consumable_changed.connect(_on_consumable_changed)

func _on_locale_changed(_new_locale: String) -> void:
	_apply_localization()

func _apply_localization() -> void:
	end_turn_button.text = Localization.t("COMBAT_END_TURN")
	$FXLayer/RelicInfoPopup/VBox/TapHint.text = Localization.t("RELIC_TAP_CLOSE")

func _setup_energy_orbs() -> void:
	energy_icon_texture = load("res://assets/energy-lightning.png")

	for i in range(5):
		var orb_container = Control.new()
		orb_container.custom_minimum_size = Vector2(50, 50)

		# Glow background
		var glow = Panel.new()
		glow.custom_minimum_size = Vector2(50, 50)
		var glow_style = StyleBoxFlat.new()
		glow_style.bg_color = Color(1, 0.85, 0.2, 0.4)
		glow_style.corner_radius_top_left = 25
		glow_style.corner_radius_top_right = 25
		glow_style.corner_radius_bottom_left = 25
		glow_style.corner_radius_bottom_right = 25
		glow.add_theme_stylebox_override("panel", glow_style)
		glow.name = "Glow"
		orb_container.add_child(glow)

		# Energy icon
		var orb = TextureRect.new()
		orb.custom_minimum_size = Vector2(44, 44)
		orb.position = Vector2(3, 3)
		orb.texture = energy_icon_texture
		orb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		orb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		orb.name = "Icon"
		orb_container.add_child(orb)

		energy_container.add_child(orb_container)
		energy_orbs.append(orb_container)
		orb_container.hide()

func _update_relics_display() -> void:
	if not relics_container:
		return

	for child in relics_container.get_children():
		child.queue_free()

	var relics = RunManager.get_relics()
	for relic in relics:
		var relic_btn = Button.new()
		relic_btn.custom_minimum_size = Vector2(50, 50)
		relic_btn.flat = true

		var style = StyleBoxFlat.new()
		var relic_color = relic.get_rarity_color()
		style.bg_color = Color(relic_color.r * 0.25, relic_color.g * 0.25, relic_color.b * 0.25, 0.95)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = relic_color
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		relic_btn.add_theme_stylebox_override("normal", style)
		relic_btn.add_theme_stylebox_override("hover", style)
		relic_btn.add_theme_stylebox_override("pressed", style)

		relic_btn.text = relic.relic_name.substr(0, 1).to_upper()
		relic_btn.add_theme_font_size_override("font_size", 22)
		relic_btn.add_theme_color_override("font_color", Color(relic_color.r * 1.4, relic_color.g * 1.4, relic_color.b * 1.4).clamp())

		# Connect tap to show popup
		relic_btn.pressed.connect(_show_relic_info.bind(relic))
		relics_container.add_child(relic_btn)

func _setup_consumables_panel() -> void:
	# Create consumables panel next to the deck info
	consumables_panel = Panel.new()
	consumables_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	consumables_panel.anchor_left = 1.0
	consumables_panel.offset_left = -130
	consumables_panel.offset_top = 510
	consumables_panel.offset_right = -8
	consumables_panel.offset_bottom = 580

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.6)
	panel_style.corner_radius_top_left = 14
	panel_style.corner_radius_top_right = 14
	panel_style.corner_radius_bottom_left = 14
	panel_style.corner_radius_bottom_right = 14
	consumables_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(consumables_panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 6
	vbox.offset_right = -6
	vbox.offset_top = 4
	vbox.offset_bottom = -4
	vbox.add_theme_constant_override("separation", 2)
	consumables_panel.add_child(vbox)

	var label = Label.new()
	label.text = "Items"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	consumables_container = HBoxContainer.new()
	consumables_container.alignment = BoxContainer.ALIGNMENT_CENTER
	consumables_container.add_theme_constant_override("separation", 8)
	vbox.add_child(consumables_container)

func _update_consumables_display() -> void:
	if not consumables_container:
		return

	for child in consumables_container.get_children():
		child.queue_free()

	var consumables = RunManager.get_consumables()
	for i in range(RunManager.MAX_CONSUMABLE_SLOTS):
		var consumable = consumables[i] if i < consumables.size() else null
		var slot_btn = Button.new()
		slot_btn.custom_minimum_size = Vector2(45, 45)

		var style = StyleBoxFlat.new()
		if consumable:
			style.bg_color = Color(0.2, 0.35, 0.25, 0.95)
			style.border_color = Color(0.4, 0.8, 0.5, 0.9)
			slot_btn.text = consumable.consumable_name.substr(0, 1).to_upper()
			slot_btn.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9))
			slot_btn.tooltip_text = consumable.consumable_name + "\n" + consumable.get_effect_description()
			slot_btn.pressed.connect(_use_consumable.bind(i))
		else:
			style.bg_color = Color(0.1, 0.1, 0.12, 0.8)
			style.border_color = Color(0.3, 0.3, 0.35, 0.6)
			slot_btn.text = "-"
			slot_btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
			slot_btn.disabled = true

		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		slot_btn.add_theme_stylebox_override("normal", style)
		slot_btn.add_theme_stylebox_override("hover", style)
		slot_btn.add_theme_stylebox_override("disabled", style)
		slot_btn.add_theme_font_size_override("font_size", 18)

		consumables_container.add_child(slot_btn)

func _on_consumable_changed(_slot: int, _consumable) -> void:
	_update_consumables_display()

func _use_consumable(slot: int) -> void:
	if combat_manager.current_state != CombatManager.CombatState.PLAYER_TURN:
		return

	var consumable = RunManager.get_consumable(slot)
	if not consumable:
		return

	AudioManager.play_card_pickup()

	# Apply consumable effect
	var effect_text = ""
	match consumable.effect_type:
		0:  # HEAL
			var heal_amount = min(consumable.effect_value, combat_manager.player_max_hp - combat_manager.player_hp)
			combat_manager.player_hp += heal_amount
			effect_text = "+%d HP" % heal_amount
		1:  # ENERGY
			combat_manager.player_energy += consumable.effect_value
			effect_text = "+%d ENERGY" % consumable.effect_value
		2:  # DAMAGE
			combat_manager.enemy_hp -= consumable.effect_value
			combat_manager.damage_dealt.emit("enemy", consumable.effect_value)
			effect_text = "-%d DMG" % consumable.effect_value
		3:  # BLOCK
			combat_manager.player_block += consumable.effect_value
			combat_manager.block_gained.emit("player", consumable.effect_value)
			effect_text = "+%d BLOCK" % consumable.effect_value
		4:  # DRAW
			combat_manager._draw_cards(consumable.effect_value)
			effect_text = "+%d CARDS" % consumable.effect_value
		5:  # GOLD
			RunManager.run_gold += consumable.effect_value
			combat_manager.gold_earned.emit(consumable.effect_value)
			effect_text = "+%d GOLD" % consumable.effect_value
		6:  # WEAKEN
			combat_manager.enemy_weakened += consumable.effect_value
			effect_text = "WEAKENED!"

	# Show effect
	_on_effect_triggered(effect_text)

	# Remove consumable
	RunManager.remove_consumable(slot)

	# Update UI
	combat_manager.player_stats_changed.emit()
	combat_manager.enemy_stats_changed.emit()
	hand.update_playable_cards(combat_manager.player_energy)

	# Check combat end
	combat_manager._check_combat_end()

func _show_relic_info(relic) -> void:
	relic_name_label.text = relic.relic_name
	relic_desc_label.text = relic.description

	# Style the popup with relic color
	var relic_color = relic.get_rarity_color()
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.05, 0.03, 0.08, 0.98)
	popup_style.border_width_left = 3
	popup_style.border_width_top = 3
	popup_style.border_width_right = 3
	popup_style.border_width_bottom = 3
	popup_style.border_color = relic_color
	popup_style.corner_radius_top_left = 16
	popup_style.corner_radius_top_right = 16
	popup_style.corner_radius_bottom_left = 16
	popup_style.corner_radius_bottom_right = 16
	popup_style.shadow_color = Color(relic_color.r, relic_color.g, relic_color.b, 0.3)
	popup_style.shadow_size = 8
	relic_info_popup.add_theme_stylebox_override("panel", popup_style)

	relic_name_label.add_theme_color_override("font_color", relic_color)

	# Animate in
	relic_info_popup.show()
	relic_info_popup.modulate.a = 0
	relic_info_popup.scale = Vector2(0.8, 0.8)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(relic_info_popup, "modulate:a", 1.0, 0.15)
	tween.tween_property(relic_info_popup, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _hide_relic_info() -> void:
	if not relic_info_popup.visible:
		return

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(relic_info_popup, "modulate:a", 0.0, 0.1)
	tween.tween_property(relic_info_popup, "scale", Vector2(0.9, 0.9), 0.1)

	await tween.finished
	relic_info_popup.hide()

func _input(event: InputEvent) -> void:
	# Close relic popup on any tap/click when visible
	if relic_info_popup.visible:
		if event is InputEventMouseButton and event.pressed:
			_hide_relic_info()
		elif event is InputEventScreenTouch and event.pressed:
			_hide_relic_info()

func _start_combat() -> void:
	result_panel.hide()
	out_of_cards_label.hide()
	gold_earned_this_combat = 0

	if GameManager.selected_character == null:
		GameManager.select_character(GameManager.CHAR_TANK)

	var character = GameManager.selected_character

	# Player portrait with skin support
	var skin_id = GameManager.get_selected_skin(character.character_name)
	if skin_id != "default" and skin_id in GameManager.AVAILABLE_SKINS:
		var skin_data = GameManager.AVAILABLE_SKINS[skin_id]
		var skin_texture = load(skin_data.preview)
		if skin_texture:
			player_portrait.texture = skin_texture
		else:
			player_portrait.texture = character.portrait
	else:
		player_portrait.texture = character.portrait

	# Enemy setup
	var enemy_index = randi() % enemy_sprites.size()
	enemy_sprite.texture = load(enemy_sprites[enemy_index])

	# Update top bar
	_update_run_info()

	# Entrance animations
	_animate_combat_entrance()

	combat_manager.start_combat(character)

	# Show boss effect announcement if applicable
	if RunManager.is_run_active:
		var encounter = RunManager.get_current_encounter_type()
		if encounter == RunManager.EncounterType.BOSS:
			var boss_effect = RunManager.get_current_boss_effect()
			if boss_effect != RunManager.BossEffect.NONE:
				await get_tree().create_timer(0.5).timeout
				_show_boss_effect_announcement()

func _update_run_info() -> void:
	if RunManager.is_run_active:
		var stage_text = "%s | %s" % [
			Localization.t("COMBAT_STAGE", [RunManager.current_stage]),
			Localization.t("COMBAT_FLOOR", [RunManager.current_floor])
		]
		if RunManager.is_in_infinite_mode():
			var milestone = RunManager.get_infinite_milestone()
			if milestone != "":
				stage_text = "[%s] %s" % [milestone, stage_text]
			else:
				stage_text = "[%s] %s" % [Localization.t("COMBAT_INFINITE"), stage_text]

		# Add seed indicator for seeded runs
		if RunManager.is_run_seeded():
			stage_text += " [%s]" % RunManager.get_run_seed()

		stage_label.text = stage_text
		gold_label.text = "%d" % RunManager.run_gold
		score_label.text = "%d" % RunManager.get_run_score()

		# Encounter type
		var encounter_type = RunManager.get_current_encounter_type()
		match encounter_type:
			RunManager.EncounterType.ELITE:
				encounter_label.text = Localization.t("COMBAT_ELITE_BATTLE")
				encounter_label.modulate = Color(1, 0.6, 0.2)
				encounter_label.show()
			RunManager.EncounterType.BOSS:
				var boss_text = Localization.t("COMBAT_BOSS_BATTLE")
				var boss_effect = RunManager.get_current_boss_effect()
				if boss_effect != RunManager.BossEffect.NONE:
					boss_text += " - " + RunManager.get_boss_effect_name()
				encounter_label.text = boss_text
				encounter_label.modulate = Color(1, 0.3, 0.3)
				encounter_label.show()
			_:
				encounter_label.hide()
	else:
		stage_label.text = Localization.t("COMBAT_QUICK_PLAY")
		gold_label.text = "0"
		score_label.text = "0"
		encounter_label.hide()

func _update_player_ui() -> void:
	player_hp_bar.max_value = combat_manager.player_max_hp
	var hp_tween = create_tween()
	hp_tween.tween_property(player_hp_bar, "value", combat_manager.player_hp, 0.3)

	player_hp_label.text = "%d / %d" % [combat_manager.player_hp, combat_manager.player_max_hp]

	if combat_manager.player_hp < combat_manager.player_max_hp * 0.3:
		player_hp_label.modulate = Color(1, 0.4, 0.4)
	else:
		player_hp_label.modulate = Color.WHITE

	if combat_manager.player_block > 0:
		player_block_label.text = "%d" % combat_manager.player_block
		player_block_label.show()
	else:
		player_block_label.hide()

	_update_energy_orbs()
	_update_deck_display()

func _update_energy_orbs() -> void:
	for i in range(energy_orbs.size()):
		var orb_container = energy_orbs[i]
		if i < combat_manager.player_max_energy:
			orb_container.show()
			var glow = orb_container.get_node_or_null("Glow")

			if i < combat_manager.player_energy:
				orb_container.modulate = Color.WHITE
				if glow:
					glow.show()
				if not orb_container.has_meta("pulsing"):
					orb_container.set_meta("pulsing", true)
					_pulse_energy_orb(orb_container)
			else:
				orb_container.modulate = Color(0.3, 0.3, 0.3, 0.5)
				if glow:
					glow.hide()
				orb_container.remove_meta("pulsing")
		else:
			orb_container.hide()

func _pulse_energy_orb(orb: Control) -> void:
	if not is_instance_valid(orb) or not orb.has_meta("pulsing"):
		return
	var glow = orb.get_node_or_null("Glow")
	if glow:
		var tween = create_tween()
		tween.tween_property(glow, "modulate:a", 0.5, 0.5).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(glow, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(_pulse_energy_orb.bind(orb))

func _update_deck_display() -> void:
	var draw_count = combat_manager.get_draw_pile_count()
	var discard_count = combat_manager.get_discard_pile_count()

	draw_pile_label.text = Localization.t("COMBAT_DRAW", [draw_count])
	discard_pile_label.text = Localization.t("COMBAT_DISCARD", [discard_count])

	if draw_count == 0 and discard_count == 0 and hand.get_card_count() > 0:
		_show_out_of_cards_splash()

func _show_out_of_cards_splash() -> void:
	if out_of_cards_label.visible:
		return

	out_of_cards_label.text = Localization.t("COMBAT_OUT_OF_CARDS")
	out_of_cards_label.show()
	out_of_cards_label.modulate.a = 0
	out_of_cards_label.scale = Vector2(0.5, 0.5)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(out_of_cards_label, "scale", Vector2(1.1, 1.1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(out_of_cards_label, "modulate:a", 1.0, 0.15)

	await tween.finished

	var hold_tween = create_tween()
	hold_tween.tween_property(out_of_cards_label, "scale", Vector2(1.0, 1.0), 0.1)
	hold_tween.tween_interval(0.8)
	hold_tween.tween_property(out_of_cards_label, "modulate:a", 0.0, 0.4)

	await hold_tween.finished
	out_of_cards_label.hide()

func _update_enemy_ui() -> void:
	enemy_hp_label.text = "%d / %d" % [combat_manager.enemy_hp, combat_manager.enemy_max_hp]
	enemy_hp_bar.max_value = combat_manager.enemy_max_hp

	var tween = create_tween()
	tween.tween_property(enemy_hp_bar, "value", combat_manager.enemy_hp, 0.3)

	if combat_manager.enemy_block > 0:
		enemy_block_label.text = "%d" % combat_manager.enemy_block
		enemy_block_label.show()
	else:
		enemy_block_label.hide()

	var intent_text = ""
	match combat_manager.enemy_intent:
		"attack":
			var dmg = combat_manager.enemy_damage
			if combat_manager.enemy_weakened > 0:
				dmg = max(0, dmg - 2)
			intent_text = "Attack %d" % dmg
		"defend":
			intent_text = "Defend"

	enemy_intent_label.text = intent_text

func _on_turn_changed(is_player_turn: bool) -> void:
	end_turn_button.disabled = not is_player_turn

	# Clear card selection when turn changes
	hand.clear_selection()

	# Update play hand button state
	if play_hand_button:
		play_hand_button.disabled = not is_player_turn
		if not is_player_turn:
			selection_label.text = "Enemy turn..."
			selection_label.modulate = Color(0.5, 0.5, 0.6)

	if is_player_turn:
		end_turn_button.text = Localization.t("COMBAT_END_TURN")
		turn_label.text = Localization.t("COMBAT_YOUR_TURN")
		turn_label.modulate = Color(0.4, 1.0, 0.5)
		if selection_label:
			selection_label.text = "Select cards to play"
			selection_label.modulate = Color(0.7, 0.7, 0.8)
		_slide_in_banner()
	else:
		end_turn_button.text = "..."
		turn_label.text = Localization.t("COMBAT_ENEMY_TURN")
		turn_label.modulate = Color(1.0, 0.4, 0.4)
		_slide_in_banner()

func _slide_in_banner() -> void:
	var banner = $TurnBanner
	banner.modulate.a = 0
	banner.scale = Vector2(0.8, 0.8)
	banner.pivot_offset = banner.size / 2

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(banner, "scale", Vector2(1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(banner, "modulate:a", 1.0, 0.2)

	await tween.finished
	await get_tree().create_timer(0.4).timeout

	var fade_tween = create_tween()
	fade_tween.tween_property(banner, "modulate:a", 0.3, 0.3)

func _on_end_turn_pressed() -> void:
	combat_manager.end_player_turn()

# === PLAY HAND BUTTON (Balatro-style) ===

func _setup_play_hand_button() -> void:
	# Create a compact container for the play hand UI (left bottom corner)
	var play_container = VBoxContainer.new()
	play_container.name = "PlayHandContainer"
	play_container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	play_container.anchor_top = 1.0
	play_container.anchor_bottom = 1.0
	play_container.anchor_left = 0.0
	play_container.anchor_right = 0.0
	play_container.offset_left = 12
	play_container.offset_right = 140
	play_container.offset_top = -180
	play_container.offset_bottom = -130
	play_container.add_theme_constant_override("separation", 4)
	play_container.alignment = BoxContainer.ALIGNMENT_CENTER
	play_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse
	add_child(play_container)

	# Selection info label (smaller)
	selection_label = Label.new()
	selection_label.text = "Tap cards to select"
	selection_label.add_theme_font_size_override("font_size", 11)
	selection_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.8))
	selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_container.add_child(selection_label)

	# Play Hand button (smaller, compact)
	play_hand_button = Button.new()
	play_hand_button.text = "PLAY"
	play_hand_button.custom_minimum_size = Vector2(120, 32)
	play_hand_button.add_theme_font_size_override("font_size", 14)
	play_hand_button.disabled = true

	# Style the button
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.35, 0.15)
	btn_style.border_width_left = 2
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.4, 0.9, 0.4)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.corner_radius_bottom_right = 8
	play_hand_button.add_theme_stylebox_override("normal", btn_style)

	var hover_style = btn_style.duplicate()
	hover_style.bg_color = Color(0.2, 0.45, 0.2)
	play_hand_button.add_theme_stylebox_override("hover", hover_style)

	var pressed_style = btn_style.duplicate()
	pressed_style.bg_color = Color(0.25, 0.55, 0.25)
	play_hand_button.add_theme_stylebox_override("pressed", pressed_style)

	var disabled_style = btn_style.duplicate()
	disabled_style.bg_color = Color(0.12, 0.12, 0.15)
	disabled_style.border_color = Color(0.3, 0.3, 0.35)
	play_hand_button.add_theme_stylebox_override("disabled", disabled_style)

	play_hand_button.pressed.connect(_on_play_hand_pressed)
	play_container.add_child(play_hand_button)

func _on_hand_selection_changed(selected_count: int, total_cost: int) -> void:
	if selected_count == 0:
		selection_label.text = "Select cards to play"
		selection_label.modulate = Color(0.7, 0.7, 0.8)
		play_hand_button.text = "PLAY HAND"
		play_hand_button.disabled = true
	else:
		var can_afford = combat_manager.player_energy >= total_cost
		if selected_count == 3:
			selection_label.text = "COMBO! %d cards (%d energy)" % [selected_count, total_cost]
			selection_label.modulate = Color(1.0, 0.85, 0.3) if can_afford else Color(1.0, 0.4, 0.4)
		else:
			selection_label.text = "%d card%s selected (%d energy)" % [selected_count, "s" if selected_count > 1 else "", total_cost]
			selection_label.modulate = Color(0.9, 0.95, 1.0) if can_afford else Color(1.0, 0.4, 0.4)

		play_hand_button.text = "PLAY HAND (%d)" % total_cost
		play_hand_button.disabled = not can_afford

func _on_play_hand_pressed() -> void:
	AudioManager.play_card_pickup()
	combat_manager.play_selected_hand()

func _on_gold_earned(amount: int) -> void:
	gold_earned_this_combat = amount

func _on_combat_ended(player_won: bool) -> void:
	result_panel.show()

	if player_won:
		result_label.text = Localization.t("COMBAT_VICTORY")
		result_label.modulate = Color(0.4, 1.0, 0.4)

		if gold_earned_this_combat > 0:
			result_gold_label.text = Localization.t("GOLD_GAINED", [gold_earned_this_combat])
			result_gold_label.show()
		else:
			result_gold_label.hide()

		continue_button.hide()
		menu_button.hide()
		_victory_animation()

		await get_tree().create_timer(1.5).timeout
		_auto_continue_run()
	else:
		result_label.text = Localization.t("COMBAT_DEFEAT")
		result_label.modulate = Color(1.0, 0.4, 0.4)
		result_gold_label.hide()
		continue_button.text = Localization.t("COMBAT_TRY_AGAIN")
		continue_button.show()
		menu_button.text = Localization.t("COMBAT_MAIN_MENU")
		menu_button.show()
		_defeat_animation()

func _auto_continue_run() -> void:
	if RunManager.is_run_active:
		# Check for relic breakage after combat
		var broken_relics = RunManager.check_relic_breakage()
		if broken_relics.size() > 0:
			await _show_broken_relics(broken_relics)

		RunManager.complete_encounter(true, combat_manager.player_hp, gold_earned_this_combat)
	else:
		_start_combat()

func _show_broken_relics(broken_relics: Array[RelicData]) -> void:
	"""Show a popup for broken relics."""
	for relic in broken_relics:
		_on_effect_triggered("%s broke!" % relic.relic_name)
		await get_tree().create_timer(0.8).timeout

	_update_relics_display()

func _show_boss_effect_announcement() -> void:
	"""Show boss effect announcement at combat start."""
	var effect_name = RunManager.get_boss_effect_name()
	var effect_desc = RunManager.get_boss_effect_description()

	# Create overlay
	var overlay = Panel.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var overlay_style = StyleBoxFlat.new()
	overlay_style.bg_color = Color(0, 0, 0, 0.7)
	overlay.add_theme_stylebox_override("panel", overlay_style)
	add_child(overlay)

	# Content
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -150
	vbox.offset_right = 150
	vbox.offset_top = -60
	vbox.offset_bottom = 60
	vbox.add_theme_constant_override("separation", 12)
	overlay.add_child(vbox)

	var title = Label.new()
	title.text = "BOSS EFFECT"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var name_label = Label.new()
	name_label.text = effect_name
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(1, 0.7, 0.3))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = effect_desc
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	# Animate in
	overlay.modulate.a = 0
	vbox.scale = Vector2(0.8, 0.8)
	vbox.pivot_offset = vbox.size / 2

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_property(vbox, "scale", Vector2(1.0, 1.0), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(2.0).timeout

	# Animate out
	var out_tween = create_tween()
	out_tween.tween_property(overlay, "modulate:a", 0.0, 0.3)

	await out_tween.finished
	overlay.queue_free()

func _on_continue_pressed() -> void:
	if RunManager.is_run_active:
		if combat_manager.player_hp > 0:
			RunManager.complete_encounter(true, combat_manager.player_hp, gold_earned_this_combat)
		else:
			RunManager.complete_encounter(false, 0, 0)
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		_start_combat()

func _on_menu_pressed() -> void:
	if RunManager.is_run_active:
		RunManager.complete_encounter(false, 0, 0)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# === PAUSE MENU ===

func _on_pause_menu_pressed() -> void:
	AudioManager.play_card_pickup()
	_show_pause_menu()

func _show_pause_menu() -> void:
	# Set process mode BEFORE pausing so panel and tween work while paused
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.show()
	pause_panel.modulate.a = 0
	pause_panel.scale = Vector2(0.9, 0.9)
	pause_panel.pivot_offset = pause_panel.size / 2

	# Pause game processing BEFORE tween so tween needs to ignore pause
	get_tree().paused = true

	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Tween runs even when paused
	tween.set_parallel(true)
	tween.tween_property(pause_panel, "modulate:a", 1.0, 0.15)
	tween.tween_property(pause_panel, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _hide_pause_menu() -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Tween runs even when paused
	tween.set_parallel(true)
	tween.tween_property(pause_panel, "modulate:a", 0.0, 0.1)
	tween.tween_property(pause_panel, "scale", Vector2(0.9, 0.9), 0.1)

	await tween.finished
	pause_panel.hide()

	# Resume game processing
	get_tree().paused = false

func _on_pause_resume_pressed() -> void:
	AudioManager.play_card_pickup()
	_hide_pause_menu()

func _on_pause_settings_pressed() -> void:
	AudioManager.play_card_pickup()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/settings_scene.tscn")

func _on_pause_main_menu_pressed() -> void:
	AudioManager.play_card_pickup()
	get_tree().paused = false
	if RunManager.is_run_active:
		RunManager.complete_encounter(false, 0, 0)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_pause_quit_pressed() -> void:
	get_tree().quit()

# === DEBUG MODE ===

func _update_debug_button_visibility() -> void:
	debug_button.visible = StatsManager.debug_mode

func _on_debug_button_pressed() -> void:
	AudioManager.play_card_pickup()
	_show_debug_panel()

func _show_debug_panel() -> void:
	debug_panel.show()
	debug_panel.modulate.a = 0
	debug_panel.scale = Vector2(0.9, 0.9)
	debug_panel.pivot_offset = debug_panel.size / 2

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(debug_panel, "modulate:a", 1.0, 0.15)
	tween.tween_property(debug_panel, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _hide_debug_panel() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(debug_panel, "modulate:a", 0.0, 0.1)
	tween.tween_property(debug_panel, "scale", Vector2(0.9, 0.9), 0.1)

	await tween.finished
	debug_panel.hide()

func _on_debug_skip_pressed() -> void:
	AudioManager.play_card_pickup()
	_hide_debug_panel()
	combat_manager.enemy_hp = 0
	combat_manager._check_combat_end()

func _on_debug_gold_pressed() -> void:
	AudioManager.play_card_pickup()
	if RunManager.is_run_active:
		RunManager.run_gold += 100
		gold_label.text = "%d" % RunManager.run_gold
	gold_earned_this_combat += 100
	_on_effect_triggered("+100 Gold")

func _on_debug_heal_pressed() -> void:
	AudioManager.play_card_pickup()
	combat_manager.player_hp = combat_manager.player_max_hp
	_update_player_ui()
	_on_effect_triggered("Full Heal!")

func _on_debug_energy_pressed() -> void:
	AudioManager.play_card_pickup()
	combat_manager.player_energy += 3
	_update_player_ui()
	_on_effect_triggered("+3 Energy")

func _on_debug_draw_pressed() -> void:
	AudioManager.play_card_pickup()
	combat_manager._draw_cards(3)
	_on_effect_triggered("+3 Cards")

func _on_debug_maxhp_pressed() -> void:
	AudioManager.play_card_pickup()
	combat_manager.player_max_hp += 20
	combat_manager.player_hp += 20
	if RunManager.is_run_active:
		RunManager.run_max_hp += 20
		RunManager.run_hp += 20
	_update_player_ui()
	_on_effect_triggered("+20 Max HP")

func _on_debug_godmode_pressed() -> void:
	AudioManager.play_card_pickup()
	god_mode_enabled = not god_mode_enabled
	if god_mode_enabled:
		debug_godmode_btn.text = "God Mode: ON"
		debug_godmode_btn.add_theme_color_override("font_color", Color(0.4, 1, 0.4))
		combat_manager.player_hp = 9999
		combat_manager.player_max_hp = 9999
		_on_effect_triggered("GOD MODE!")
	else:
		debug_godmode_btn.text = "God Mode: OFF"
		debug_godmode_btn.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		_on_effect_triggered("Mortal again")
	_update_player_ui()

func _on_debug_skipstage_pressed() -> void:
	AudioManager.play_card_pickup()
	if RunManager.is_run_active:
		# Skip 10 stages worth of progress
		RunManager.current_stage += 10
		RunManager.current_floor += 30  # ~3 floors per stage
		_update_run_info()
		_on_effect_triggered("+10 Stages!")

func _on_debug_close_pressed() -> void:
	AudioManager.play_card_pickup()
	_hide_debug_panel()

# === ANIMATIONS ===

func _animate_combat_entrance() -> void:
	_animate_player_entrance()
	_animate_enemy_entrance()

func _animate_player_entrance() -> void:
	player_portrait.modulate.a = 0
	player_portrait.position.x -= 30

	var original_x = player_portrait.position.x + 30
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_portrait, "modulate:a", 1.0, 0.3)
	tween.tween_property(player_portrait, "position:x", original_x, 0.4).set_ease(Tween.EASE_OUT)

func _animate_enemy_entrance() -> void:
	enemy_sprite.modulate.a = 0
	enemy_sprite.position.x += 30

	var original_x = enemy_sprite.position.x - 30
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(enemy_sprite, "modulate:a", 1.0, 0.3)
	tween.tween_property(enemy_sprite, "position:x", original_x, 0.4).set_ease(Tween.EASE_OUT)

func _on_damage_dealt(target: String, amount: int) -> void:
	if amount <= 0:
		return

	AudioManager.play_punch()

	if not StatsManager.show_damage_numbers:
		return

	damage_label.text = "-%d" % amount
	damage_label.modulate = Color(1, 0.3, 0.3)

	if target == "enemy":
		damage_label.position = enemy_sprite.global_position + Vector2(30, 40)
		_shake_node(enemy_sprite)
	else:
		damage_label.position = player_portrait.global_position + Vector2(30, 40)
		if StatsManager.screen_shake:
			_screen_shake()
		_flash_portrait()

	damage_label.show()
	damage_label.scale = Vector2(1.3, 1.3)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 50, 0.5)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(damage_label, "scale", Vector2(1.0, 1.0), 0.2)

	await tween.finished
	damage_label.hide()
	damage_label.modulate.a = 1.0

func _on_block_gained(target: String, amount: int) -> void:
	if amount <= 0:
		return

	effect_label.text = "+%d" % amount
	effect_label.modulate = Color(0.3, 0.6, 1.0)

	if target == "enemy":
		effect_label.position = enemy_sprite.global_position + Vector2(40, 60)
	else:
		effect_label.position = player_portrait.global_position + Vector2(40, 60)

	effect_label.show()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect_label, "position:y", effect_label.position.y - 35, 0.4)
	tween.tween_property(effect_label, "modulate:a", 0.0, 0.4)

	await tween.finished
	effect_label.hide()
	effect_label.modulate.a = 1.0

func _on_effect_triggered(effect: String) -> void:
	effect_label.text = effect
	effect_label.modulate = Color(1, 0.9, 0.3)
	effect_label.position = Vector2(size.x / 2 - 60, size.y / 2 - 50)

	effect_label.show()
	effect_label.scale = Vector2(0.5, 0.5)

	var tween = create_tween()
	tween.tween_property(effect_label, "scale", Vector2(1.2, 1.2), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(effect_label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(effect_label, "modulate:a", 0.0, 0.35)

	await tween.finished
	effect_label.hide()
	effect_label.modulate.a = 1.0
	effect_label.scale = Vector2(1.0, 1.0)

func _shake_node(node: Node) -> void:
	var original_pos = node.position
	var tween = create_tween()
	tween.tween_property(node, "position", original_pos + Vector2(8, 0), 0.03)
	tween.tween_property(node, "position", original_pos + Vector2(-8, 0), 0.03)
	tween.tween_property(node, "position", original_pos + Vector2(5, 0), 0.03)
	tween.tween_property(node, "position", original_pos + Vector2(-5, 0), 0.03)
	tween.tween_property(node, "position", original_pos, 0.03)

func _screen_shake() -> void:
	var original_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(8, 4), 0.025)
	tween.tween_property(self, "position", original_pos + Vector2(-8, -4), 0.025)
	tween.tween_property(self, "position", original_pos + Vector2(4, 2), 0.025)
	tween.tween_property(self, "position", original_pos, 0.025)

func _flash_portrait() -> void:
	var tween = create_tween()
	tween.tween_property(player_portrait, "modulate", Color(1, 0.4, 0.4), 0.1)
	tween.tween_property(player_portrait, "modulate", Color.WHITE, 0.15)

func _victory_animation() -> void:
	result_panel.scale = Vector2(0.3, 0.3)
	result_panel.modulate.a = 0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(result_panel, "scale", Vector2(1.0, 1.0), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(result_panel, "modulate:a", 1.0, 0.2)

func _defeat_animation() -> void:
	result_panel.scale = Vector2(1.2, 1.2)
	result_panel.modulate.a = 0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(result_panel, "scale", Vector2(1.0, 1.0), 0.25)
	tween.tween_property(result_panel, "modulate:a", 1.0, 0.2)

func _on_run_completed() -> void:
	result_panel.hide()
	_show_run_complete_screen()

func _show_run_complete_screen() -> void:
	if run_complete_panel:
		run_complete_panel.queue_free()

	run_complete_panel = Panel.new()
	run_complete_panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var overlay_style = StyleBoxFlat.new()
	overlay_style.bg_color = Color(0.02, 0.01, 0.05, 0.9)
	run_complete_panel.add_theme_stylebox_override("panel", overlay_style)
	add_child(run_complete_panel)

	var card = Panel.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -160
	card.offset_right = 160
	card.offset_top = -200
	card.offset_bottom = 200

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.05, 0.03, 0.1, 0.95)
	card_style.border_width_left = 3
	card_style.border_width_top = 3
	card_style.border_width_right = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color(1, 0.7, 0.3, 0.8)
	card_style.corner_radius_top_left = 20
	card_style.corner_radius_top_right = 20
	card_style.corner_radius_bottom_left = 20
	card_style.corner_radius_bottom_right = 20
	card.add_theme_stylebox_override("panel", card_style)
	run_complete_panel.add_child(card)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 20
	main_vbox.offset_right = -20
	main_vbox.offset_top = 20
	main_vbox.offset_bottom = -20
	main_vbox.add_theme_constant_override("separation", 14)
	card.add_child(main_vbox)

	var title = Label.new()
	title.text = Localization.t("RUN_COMPLETE_TITLE")
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title)

	var stats_label = Label.new()
	stats_label.text = "%s  |  %s" % [
		Localization.t("COMBAT_STAGE", [RunManager.current_stage]),
		Localization.t("RUN_COMPLETE_SCORE", [RunManager.get_run_score()])
	]
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(stats_label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(spacer)

	var infinite_btn = Button.new()
	infinite_btn.text = Localization.t("RUN_INFINITE_MODE")
	infinite_btn.custom_minimum_size = Vector2(0, 50)
	infinite_btn.add_theme_font_size_override("font_size", 18)
	infinite_btn.pressed.connect(_on_infinite_mode_pressed)
	main_vbox.add_child(infinite_btn)

	var end_btn = Button.new()
	end_btn.text = Localization.t("RUN_END_VICTORY")
	end_btn.custom_minimum_size = Vector2(0, 45)
	end_btn.add_theme_font_size_override("font_size", 14)
	end_btn.pressed.connect(_on_end_run_victory_pressed)
	main_vbox.add_child(end_btn)

	run_complete_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(run_complete_panel, "modulate:a", 1.0, 0.3)

	VFXManager.victory_burst(run_complete_panel)

func _on_infinite_mode_pressed() -> void:
	AudioManager.play_card_pickup()
	if run_complete_panel:
		run_complete_panel.queue_free()
		run_complete_panel = null
	RunManager.continue_to_infinite_mode()

func _on_end_run_victory_pressed() -> void:
	AudioManager.play_card_pickup()
	if run_complete_panel:
		run_complete_panel.queue_free()
		run_complete_panel = null
	RunManager.end_run_with_victory()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
