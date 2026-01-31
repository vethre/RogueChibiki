extends Control

# Base path for cleaner code
const BASE = "SafeArea/MainVBox/ScrollContainer/Content"

# Title
@onready var title_label: Label = $"SafeArea/MainVBox/Title"

# Section headers
@onready var gameplay_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/GameplayLabel"
@onready var visual_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/VisualSection/VisualMargin/VisualContent/VisualLabel"
@onready var audio_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/AudioLabel"
@onready var display_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/DisplayLabel"
@onready var language_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/LanguageSection/LanguageMargin/LanguageContent/LanguageLabel"
@onready var data_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/DataSection/DataMargin/DataContent/DataLabel"

# Gameplay settings
@onready var auto_end_turn_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/AutoEndTurnCheck"
@onready var confirm_card_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/ConfirmCardCheck"
@onready var debug_mode_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/DebugModeCheck"
@onready var anim_speed_name_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/AnimSpeedRow/AnimSpeedLabel"
@onready var anim_speed_slider: HSlider = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/AnimSpeedRow/AnimSpeedSlider"
@onready var anim_speed_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/GameplaySection/GameplayMargin/GameplayContent/AnimSpeedRow/AnimSpeedValue"

# Visual settings
@onready var screen_shake_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/VisualSection/VisualMargin/VisualContent/ScreenShakeCheck"
@onready var damage_numbers_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/VisualSection/VisualMargin/VisualContent/DamageNumbersCheck"
@onready var particles_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/VisualSection/VisualMargin/VisualContent/ParticlesCheck"
@onready var glare_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/VisualSection/VisualMargin/VisualContent/GlareCheck"
@onready var reduced_motion_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/VisualSection/VisualMargin/VisualContent/ReducedMotionCheck"

# Audio settings
@onready var music_name_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/MusicRow/MusicLabel"
@onready var music_slider: HSlider = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/MusicRow/MusicSlider"
@onready var music_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/MusicRow/MusicValue"
@onready var sfx_name_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/SFXRow/SFXLabel"
@onready var sfx_slider: HSlider = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/SFXRow/SFXSlider"
@onready var sfx_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/SFXRow/SFXValue"
@onready var haptic_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/AudioSection/AudioMargin/AudioContent/HapticCheck"

# Display settings
@onready var ui_scale_name_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/UIScaleRow/UIScaleLabel"
@onready var ui_scale_slider: HSlider = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/UIScaleRow/UIScaleSlider"
@onready var ui_scale_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/UIScaleRow/UIScaleValue"
@onready var card_size_name_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/CardSizeRow/CardSizeLabel"
@onready var card_size_slider: HSlider = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/CardSizeRow/CardSizeSlider"
@onready var card_size_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/CardSizeRow/CardSizeValue"
@onready var high_contrast_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/HighContrastCheck"
@onready var card_borders_check: CheckBox = $"SafeArea/MainVBox/ScrollContainer/Content/DisplaySection/DisplayMargin/DisplayContent/CardBordersCheck"

# Language settings
@onready var language_name_label: Label = $"SafeArea/MainVBox/ScrollContainer/Content/LanguageSection/LanguageMargin/LanguageContent/LanguageRow/LanguageNameLabel"
@onready var language_option: OptionButton = $"SafeArea/MainVBox/ScrollContainer/Content/LanguageSection/LanguageMargin/LanguageContent/LanguageRow/LanguageOption"

const LANGUAGES = [
	{"code": "en", "name": "English"},
	{"code": "uk", "name": "Українська"},
	{"code": "ru", "name": "Русский"}
]

# Data section
@onready var reset_stats_btn: Button = $"SafeArea/MainVBox/ScrollContainer/Content/DataSection/DataMargin/DataContent/ResetStatsBtn"
@onready var back_btn: Button = $"SafeArea/MainVBox/BackButton"

# Confirm dialog
@onready var confirm_panel: Panel = $ConfirmPanel
@onready var confirm_label: Label = $"ConfirmPanel/VBox/ConfirmLabel"
@onready var confirm_yes_btn: Button = $"ConfirmPanel/VBox/Buttons/YesButton"
@onready var confirm_no_btn: Button = $"ConfirmPanel/VBox/Buttons/NoButton"

# Scroll container for touch scrolling
@onready var scroll_container: ScrollContainer = $"SafeArea/MainVBox/ScrollContainer"

# Touch scrolling variables
var _touch_start_y: float = 0.0
var _scroll_start: float = 0.0
var _is_dragging: bool = false
var _drag_threshold: float = 10.0

func _ready() -> void:
	_load_settings()
	_connect_signals()
	confirm_panel.hide()
	_update_ui_text()

	# Refresh UI when language changes
	Localization.locale_changed.connect(_on_locale_changed)

func _input(event: InputEvent) -> void:
	# Handle touch scrolling for mobile
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start_y = event.position.y
			_scroll_start = scroll_container.scroll_vertical
			_is_dragging = false
		else:
			_is_dragging = false
	elif event is InputEventScreenDrag:
		var delta_y = _touch_start_y - event.position.y
		if abs(delta_y) > _drag_threshold:
			_is_dragging = true
		if _is_dragging:
			scroll_container.scroll_vertical = _scroll_start + int(delta_y)

func _on_locale_changed(_new_locale: String) -> void:
	_update_ui_text()

func _update_ui_text() -> void:
	# Title
	title_label.text = Localization.t("SETTINGS_TITLE")

	# Section headers
	gameplay_label.text = Localization.t("SETTINGS_GAMEPLAY")
	visual_label.text = Localization.t("SETTINGS_VISUAL")
	audio_label.text = Localization.t("SETTINGS_AUDIO")
	display_label.text = Localization.t("SETTINGS_DISPLAY")
	language_label.text = Localization.t("SETTINGS_LANGUAGE")
	data_label.text = Localization.t("SETTINGS_DATA")

	# Gameplay section
	auto_end_turn_check.text = Localization.t("SETTINGS_AUTO_END_TURN")
	confirm_card_check.text = Localization.t("SETTINGS_CONFIRM_CARD")
	debug_mode_check.text = Localization.t("SETTINGS_DEBUG_MODE")
	anim_speed_name_label.text = Localization.t("SETTINGS_ANIM_SPEED")

	# Visual section
	screen_shake_check.text = Localization.t("SETTINGS_SCREEN_SHAKE")
	damage_numbers_check.text = Localization.t("SETTINGS_DAMAGE_NUMBERS")
	particles_check.text = Localization.t("SETTINGS_PARTICLES")
	glare_check.text = Localization.t("SETTINGS_GLARE")
	reduced_motion_check.text = Localization.t("SETTINGS_REDUCED_MOTION")

	# Audio section
	music_name_label.text = Localization.t("SETTINGS_MUSIC")
	sfx_name_label.text = Localization.t("SETTINGS_SFX")
	haptic_check.text = Localization.t("SETTINGS_HAPTIC")

	# Display section
	ui_scale_name_label.text = Localization.t("SETTINGS_UI_SCALE")
	card_size_name_label.text = Localization.t("SETTINGS_CARD_SIZE")
	high_contrast_check.text = Localization.t("SETTINGS_HIGH_CONTRAST")
	card_borders_check.text = Localization.t("SETTINGS_CARD_BORDERS")

	# Data section
	reset_stats_btn.text = Localization.t("SETTINGS_RESET_STATS")
	back_btn.text = Localization.t("SETTINGS_BACK")

	# Confirm dialog
	confirm_label.text = Localization.t("SETTINGS_CONFIRM_RESET")
	confirm_yes_btn.text = Localization.t("SETTINGS_YES")
	confirm_no_btn.text = Localization.t("SETTINGS_NO")

func _load_settings() -> void:
	# Gameplay
	auto_end_turn_check.button_pressed = StatsManager.auto_end_turn
	confirm_card_check.button_pressed = StatsManager.confirm_card_play
	debug_mode_check.button_pressed = StatsManager.debug_mode
	anim_speed_slider.value = StatsManager.animation_speed
	_update_anim_speed_label()

	# Visual
	screen_shake_check.button_pressed = StatsManager.screen_shake
	damage_numbers_check.button_pressed = StatsManager.show_damage_numbers
	particles_check.button_pressed = StatsManager.show_particles
	glare_check.button_pressed = StatsManager.show_glare
	reduced_motion_check.button_pressed = StatsManager.reduced_motion

	# Audio
	music_slider.value = StatsManager.music_volume
	sfx_slider.value = StatsManager.sfx_volume
	haptic_check.button_pressed = StatsManager.haptic_feedback
	_update_music_label()
	_update_sfx_label()

	# Display
	ui_scale_slider.value = StatsManager.ui_scale
	card_size_slider.value = StatsManager.card_size
	high_contrast_check.button_pressed = StatsManager.high_contrast
	card_borders_check.button_pressed = StatsManager.show_card_borders
	_update_ui_scale_label()
	_update_card_size_label()

	# Language
	_setup_language_options()

func _connect_signals() -> void:
	# Gameplay
	auto_end_turn_check.toggled.connect(_on_auto_end_turn_toggled)
	confirm_card_check.toggled.connect(_on_confirm_card_toggled)
	debug_mode_check.toggled.connect(_on_debug_mode_toggled)
	anim_speed_slider.value_changed.connect(_on_anim_speed_changed)

	# Visual
	screen_shake_check.toggled.connect(_on_screen_shake_toggled)
	damage_numbers_check.toggled.connect(_on_damage_numbers_toggled)
	particles_check.toggled.connect(_on_particles_toggled)
	glare_check.toggled.connect(_on_glare_toggled)
	reduced_motion_check.toggled.connect(_on_reduced_motion_toggled)

	# Audio
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	haptic_check.toggled.connect(_on_haptic_toggled)

	# Display
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	card_size_slider.value_changed.connect(_on_card_size_changed)
	high_contrast_check.toggled.connect(_on_high_contrast_toggled)
	card_borders_check.toggled.connect(_on_card_borders_toggled)

	# Language
	language_option.item_selected.connect(_on_language_selected)

	# Data
	reset_stats_btn.pressed.connect(_on_reset_stats_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	confirm_yes_btn.pressed.connect(_on_confirm_yes)
	confirm_no_btn.pressed.connect(_on_confirm_no)

# Gameplay handlers
func _on_auto_end_turn_toggled(pressed: bool) -> void:
	StatsManager.auto_end_turn = pressed
	StatsManager.save_stats()

func _on_confirm_card_toggled(pressed: bool) -> void:
	StatsManager.confirm_card_play = pressed
	StatsManager.save_stats()

func _on_debug_mode_toggled(pressed: bool) -> void:
	StatsManager.debug_mode = pressed
	StatsManager.save_stats()

func _on_anim_speed_changed(value: float) -> void:
	StatsManager.animation_speed = value
	_update_anim_speed_label()
	StatsManager.save_stats()

func _update_anim_speed_label() -> void:
	anim_speed_label.text = "%.1fx" % StatsManager.animation_speed

# Visual handlers
func _on_screen_shake_toggled(pressed: bool) -> void:
	StatsManager.screen_shake = pressed
	StatsManager.save_stats()

func _on_damage_numbers_toggled(pressed: bool) -> void:
	StatsManager.show_damage_numbers = pressed
	StatsManager.save_stats()

func _on_particles_toggled(pressed: bool) -> void:
	StatsManager.show_particles = pressed
	StatsManager.save_stats()

func _on_glare_toggled(pressed: bool) -> void:
	StatsManager.show_glare = pressed
	StatsManager.save_stats()

func _on_reduced_motion_toggled(pressed: bool) -> void:
	StatsManager.reduced_motion = pressed
	StatsManager.save_stats()

# Audio handlers
func _on_music_changed(value: float) -> void:
	StatsManager.music_volume = value
	AudioManager.set_music_volume(value)
	_update_music_label()
	StatsManager.save_stats()

func _update_music_label() -> void:
	music_label.text = "%d%%" % int(StatsManager.music_volume * 100)

func _on_sfx_changed(value: float) -> void:
	StatsManager.sfx_volume = value
	AudioManager.set_sfx_volume(value)
	_update_sfx_label()
	StatsManager.save_stats()
	# Play a test sound so user can hear the new volume
	AudioManager.play_card_pickup()

func _update_sfx_label() -> void:
	sfx_label.text = "%d%%" % int(StatsManager.sfx_volume * 100)

func _on_haptic_toggled(pressed: bool) -> void:
	StatsManager.haptic_feedback = pressed
	StatsManager.save_stats()

# Display handlers
func _on_ui_scale_changed(value: float) -> void:
	StatsManager.ui_scale = value
	_update_ui_scale_label()
	StatsManager.save_stats()

func _update_ui_scale_label() -> void:
	ui_scale_label.text = "%.0f%%" % (StatsManager.ui_scale * 100)

func _on_card_size_changed(value: float) -> void:
	StatsManager.card_size = value
	_update_card_size_label()
	StatsManager.save_stats()

func _update_card_size_label() -> void:
	card_size_label.text = "%.0f%%" % (StatsManager.card_size * 100)

func _on_high_contrast_toggled(pressed: bool) -> void:
	StatsManager.high_contrast = pressed
	StatsManager.save_stats()

func _on_card_borders_toggled(pressed: bool) -> void:
	StatsManager.show_card_borders = pressed
	StatsManager.save_stats()

# Language handlers
func _setup_language_options() -> void:
	language_option.clear()
	var current_index = 0
	for i in range(LANGUAGES.size()):
		var lang = LANGUAGES[i]
		language_option.add_item(lang.name, i)
		if lang.code == StatsManager.language:
			current_index = i
	language_option.selected = current_index

func _on_language_selected(index: int) -> void:
	var lang_code = LANGUAGES[index].code
	StatsManager.language = lang_code
	Localization.set_locale(lang_code)
	StatsManager.save_stats()

# Data handlers
func _on_reset_stats_pressed() -> void:
	confirm_panel.show()

func _on_confirm_yes() -> void:
	StatsManager.reset_stats()
	confirm_panel.hide()

func _on_confirm_no() -> void:
	confirm_panel.hide()

func _on_back_pressed() -> void:
	AudioManager.play_card_pickup()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
