extends Control

@onready var back_button: Button = $SafeArea/MainVBox/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_animate_entrance()

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
