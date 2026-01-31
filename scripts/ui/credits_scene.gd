extends Control

@onready var back_button: Button = $SafeArea/MainVBox/BackButton
@onready var website_link: Label = $SafeArea/MainVBox/CreditsPanel/CreditsMargin/CreditsScroll/CreditsContent/WebsiteSection/WebsiteLink

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_setup_website_link()
	_animate_entrance()

func _setup_website_link() -> void:
	# Make website label clickable
	if website_link:
		website_link.mouse_filter = Control.MOUSE_FILTER_STOP
		website_link.gui_input.connect(_on_website_clicked)
		website_link.mouse_entered.connect(_on_website_hover.bind(true))
		website_link.mouse_exited.connect(_on_website_hover.bind(false))

func _on_website_hover(hovering: bool) -> void:
	if hovering:
		website_link.add_theme_color_override("font_color", Color(1, 1, 1))
		website_link.text = "> roguechibiki.space <"
	else:
		website_link.add_theme_color_override("font_color", Color(0.6, 0.9, 1))
		website_link.text = "roguechibiki.space"

func _on_website_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_card_pickup()
		OS.shell_open("https://roguechibiki.space")

func _animate_entrance() -> void:
	var credits_panel = $SafeArea/MainVBox/CreditsPanel
	var title = $SafeArea/MainVBox/TitleLabel

	title.modulate.a = 0
	credits_panel.modulate.a = 0
	back_button.modulate.a = 0

	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.3)
	tween.tween_property(credits_panel, "modulate:a", 1.0, 0.4)
	tween.tween_property(back_button, "modulate:a", 1.0, 0.2)

func _on_back_pressed() -> void:
	AudioManager.play_card_pickup()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
