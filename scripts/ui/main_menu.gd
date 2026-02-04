extends Control

@onready var play_button: Button = $SafeArea/MainHBox/RightPanel/PlayButton
@onready var settings_button: Button = $SafeArea/MainHBox/RightPanel/SettingsButton
@onready var credits_button: Button = $SafeArea/MainHBox/RightPanel/CreditsButton
@onready var skins_button: Button = $SafeArea/MainHBox/RightPanel/SkinsButton
@onready var web_button: Button = $SafeArea/MainHBox/RightPanel/InfoButton  # Renamed to Web
@onready var quit_button: Button = $SafeArea/MainHBox/RightPanel/QuitButton
@onready var bouquet_label: Label = $BouquetPanel/HBox/BouquetLabel

# Logo
@onready var logo: TextureRect = $SafeArea/MainHBox/LeftPanel/LogoContainer/Logo
@onready var goth_splash: TextureRect = $SafeArea/MainHBox/LeftPanel/SplashContainer/GothSplash

# Stats labels
@onready var stats_panel: Panel = $SafeArea/MainHBox/LeftPanel/StatsPanel
@onready var runs_label: Label = $SafeArea/MainHBox/LeftPanel/StatsPanel/StatsMargin/StatsContainer/StatsGrid/RunsLabel
@onready var wins_label: Label = $SafeArea/MainHBox/LeftPanel/StatsPanel/StatsMargin/StatsContainer/StatsGrid/WinsLabel
@onready var best_floor_label: Label = $SafeArea/MainHBox/LeftPanel/StatsPanel/StatsMargin/StatsContainer/StatsGrid/BestFloorLabel
@onready var playstyle_label: Label = $SafeArea/MainHBox/LeftPanel/StatsPanel/StatsMargin/StatsContainer/StatsGrid/PlaystyleLabel
@onready var best_score_label: Label = $SafeArea/MainHBox/LeftPanel/StatsPanel/StatsMargin/StatsContainer/StatsGrid/BestScoreLabel
@onready var completions_label: Label = $SafeArea/MainHBox/LeftPanel/StatsPanel/StatsMargin/StatsContainer/StatsGrid/CompletionsLabel

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	skins_button.pressed.connect(_on_skins_pressed)
	web_button.pressed.connect(_on_web_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Refresh UI when language changes
	Localization.locale_changed.connect(_on_locale_changed)

	_update_ui_text()
	_animate_logo_tilt()
	_animate_splash_tilt()
	_animate_entrance()
	_update_stats()
	_update_bouquets()

	# Play main menu music (combat/chill jazz)
	AudioManager.play_combat_music()

func _on_locale_changed(_new_locale: String) -> void:
	_update_ui_text()
	_update_stats()

func _update_ui_text() -> void:
	play_button.text = Localization.t("MENU_PLAY")
	settings_button.text = Localization.t("MENU_SETTINGS")
	credits_button.text = Localization.t("MENU_CREDITS")
	skins_button.text = Localization.t("MENU_SKINS")
	web_button.text = "WEB"  # Opens roguechibiki.space
	quit_button.text = Localization.t("MENU_QUIT")

func _update_bouquets() -> void:
	bouquet_label.text = str(GameManager.get_bouquets())

func _animate_logo_tilt() -> void:
	if StatsManager.reduced_motion:
		return

	# Set pivot to center for rotation
	logo.pivot_offset = logo.size / 2

	# Gentle tilting animation
	var tween = create_tween().set_loops()
	tween.tween_property(logo, "rotation_degrees", 2.0, 2.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(logo, "rotation_degrees", -2.0, 2.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	# Also add a subtle scale pulse
	var scale_tween = create_tween().set_loops()
	scale_tween.tween_property(logo, "scale", Vector2(1.02, 1.02), 3.0).set_ease(Tween.EASE_IN_OUT)
	scale_tween.tween_property(logo, "scale", Vector2(1.0, 1.0), 3.0).set_ease(Tween.EASE_IN_OUT)

func _animate_splash_tilt() -> void:
	if StatsManager.reduced_motion:
		return

	# Set pivot to center for rotation
	goth_splash.pivot_offset = goth_splash.size / 2

	# Gentle tilting animation (opposite direction to logo for visual interest)
	var tween = create_tween().set_loops()
	tween.tween_property(goth_splash, "rotation_degrees", -1.5, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(goth_splash, "rotation_degrees", 1.5, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	# Subtle floating effect
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(goth_splash, "position:y", goth_splash.position.y - 5, 1.8).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(goth_splash, "position:y", goth_splash.position.y + 5, 1.8).set_ease(Tween.EASE_IN_OUT)

func _animate_entrance() -> void:
	# Fade in buttons sequentially
	play_button.modulate.a = 0
	settings_button.modulate.a = 0
	credits_button.modulate.a = 0
	skins_button.modulate.a = 0
	web_button.modulate.a = 0
	quit_button.modulate.a = 0
	stats_panel.modulate.a = 0
	logo.modulate.a = 0
	goth_splash.modulate.a = 0

	# Logo entrance
	logo.scale = Vector2(0.8, 0.8)
	goth_splash.scale = Vector2(0.8, 0.8)

	await get_tree().create_timer(0.1).timeout

	var logo_tween = create_tween()
	logo_tween.set_parallel(true)
	logo_tween.tween_property(logo, "modulate:a", 1.0, 0.5)
	logo_tween.tween_property(logo, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(0.15).timeout

	# Goth splash entrance
	var splash_tween = create_tween()
	splash_tween.set_parallel(true)
	splash_tween.tween_property(goth_splash, "modulate:a", 1.0, 0.4)
	splash_tween.tween_property(goth_splash, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(0.1).timeout

	var tween = create_tween()
	tween.tween_property(play_button, "modulate:a", 1.0, 0.2)
	tween.tween_property(settings_button, "modulate:a", 1.0, 0.2)
	tween.tween_property(credits_button, "modulate:a", 1.0, 0.2)
	tween.tween_property(skins_button, "modulate:a", 1.0, 0.2)
	tween.tween_property(web_button, "modulate:a", 1.0, 0.2)
	tween.tween_property(quit_button, "modulate:a", 1.0, 0.2)
	tween.tween_property(stats_panel, "modulate:a", 1.0, 0.3)

func _update_stats() -> void:
	runs_label.text = Localization.t("MENU_RUNS", [StatsManager.total_runs])

	if StatsManager.total_runs > 0:
		var win_rate = float(StatsManager.total_wins) / StatsManager.total_runs * 100.0
		wins_label.text = Localization.t("MENU_WINS", [StatsManager.total_wins]) + " (%.0f%%)" % win_rate
	else:
		wins_label.text = Localization.t("MENU_WINS", [0])

	best_floor_label.text = Localization.t("MENU_BEST_FLOOR", [StatsManager.best_floor])
	best_score_label.text = Localization.t("MENU_BEST_SCORE", [StatsManager.best_score])
	completions_label.text = Localization.t("MENU_COMPLETIONS", [StatsManager.total_main_runs_completed])

	# Calculate playstyle
	var total_cards = StatsManager.total_attack_cards_played + StatsManager.total_defend_cards_played
	if total_cards > 10:
		var attack_ratio = float(StatsManager.total_attack_cards_played) / total_cards
		if attack_ratio > 0.65:
			playstyle_label.text = Localization.t("MENU_STYLE", [Localization.t("STYLE_AGGRO")])
			playstyle_label.modulate = Color(1, 0.5, 0.5)
		elif attack_ratio < 0.35:
			playstyle_label.text = Localization.t("MENU_STYLE", [Localization.t("STYLE_TANK")])
			playstyle_label.modulate = Color(0.5, 0.7, 1)
		else:
			playstyle_label.text = Localization.t("MENU_STYLE", [Localization.t("STYLE_BALANCED")])
			playstyle_label.modulate = Color(0.7, 1, 0.7)
	else:
		playstyle_label.text = Localization.t("MENU_STYLE", [Localization.t("STYLE_UNKNOWN")])
		playstyle_label.modulate = Color(0.6, 0.6, 0.6)

func _on_play_pressed() -> void:
	AudioManager.play_card_pickup()
	VFXManager.transition_to_scene("res://scenes/ui/character_select.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_card_pickup()
	VFXManager.transition_to_scene("res://scenes/ui/settings_scene.tscn")

func _on_credits_pressed() -> void:
	AudioManager.play_card_pickup()
	VFXManager.transition_to_scene("res://scenes/ui/credits_scene.tscn")

func _on_skins_pressed() -> void:
	AudioManager.play_card_pickup()
	VFXManager.transition_to_scene("res://scenes/ui/skins_scene.tscn")

func _on_web_pressed() -> void:
	AudioManager.play_card_pickup()
	OS.shell_open("https://roguechibiki.space")

func _on_quit_pressed() -> void:
	VFXManager.fade_out(0.3)
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
