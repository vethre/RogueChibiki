extends Control

@onready var floor_label: Label = $TopBar/FloorLabel
@onready var hp_label: Label = $TopBar/HPLabel

@onready var rest_btn: Button = $OptionsContainer/RestButton
@onready var upgrade_btn: Button = $OptionsContainer/UpgradeButton
@onready var train_btn: Button = $OptionsContainer/TrainButton

var heal_amount: int = 0
var upgrade_panel_visible: bool = false

func _ready() -> void:
	heal_amount = int(RunManager.run_max_hp * 0.3)

	rest_btn.pressed.connect(_on_rest)
	upgrade_btn.pressed.connect(_on_upgrade)
	train_btn.pressed.connect(_on_train)

	_update_ui()

func _update_ui() -> void:
	floor_label.text = "Stage: %d | Floor: %d" % [RunManager.current_stage, RunManager.current_floor]
	hp_label.text = "HP: %d/%d" % [RunManager.run_hp, RunManager.run_max_hp]

	rest_btn.text = "Rest\nHeal %d HP" % heal_amount
	rest_btn.disabled = RunManager.run_hp >= RunManager.run_max_hp

	# Check if there are upgradeable cards
	var upgradeable = RunManager.get_upgradeable_cards()
	upgrade_btn.disabled = upgradeable.size() == 0
	if upgradeable.size() == 0:
		upgrade_btn.text = "Upgrade\n(No cards)"
	else:
		upgrade_btn.text = "Upgrade\nEnhance a Card"

	train_btn.text = "Train\n+1 Max Energy"

func _on_rest() -> void:
	RunManager.heal(heal_amount)
	_continue()

func _on_upgrade() -> void:
	# Upgrade a random upgradeable card
	var upgradeable = RunManager.get_upgradeable_cards()
	if upgradeable.size() > 0:
		var random_index = upgradeable[randi() % upgradeable.size()]
		RunManager.upgrade_card(random_index)
		var card = RunManager.run_deck[random_index]
		# Could show a message here
	_continue()

func _on_train() -> void:
	# Boost energy for this run
	RunManager.add_upgrade("energy", 1)
	_continue()

func _continue() -> void:
	RunManager.complete_encounter(true, RunManager.run_hp, 0)
