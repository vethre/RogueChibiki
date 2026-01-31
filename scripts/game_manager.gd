extends Node

# Singleton for global game state

signal character_selected(character: CharacterData)
signal bouquets_changed(total: int)
signal skin_unlocked(skin_id: String)

# Character resources
const CHAR_TANK = preload("res://data/characters/char_tank.tres")
const CHAR_AGGRO = preload("res://data/characters/char_aggro.tres")
const CHAR_CONTROL = preload("res://data/characters/char_control.tres")
const CHAR_COMBO = preload("res://data/characters/char_combo.tres")
const CHAR_EVELONE = preload("res://data/characters/char_evelone.tres")
const CHAR_BUSTER = preload("res://data/characters/char_buster.tres")
const CHAR_MOKRIVSKYI = preload("res://data/characters/char_mokrivskyi.tres")
const CHAR_CHRISWAVE = preload("res://data/characters/char_chriswave.tres")
const CHAR_GAECHKA = preload("res://data/characters/char_gaechka.tres")

# Card resources
const CARD_STRIKE = preload("res://data/card_strike.tres")
const CARD_DEFEND = preload("res://data/card_defend.tres")
const CARD_IRON_WALL = preload("res://data/card_iron_wall.tres")
const CARD_RAGE = preload("res://data/card_rage.tres")
const CARD_WEAKEN = preload("res://data/card_weaken.tres")
const CARD_QUICK_DRAW = preload("res://data/card_quick_draw.tres")

# Character-specific cards (obtained via character's starting deck)
const CARD_OVERCHARGE = preload("res://data/card_overcharge.tres")
const CARD_FORTIFY = preload("res://data/card_fortify.tres")
const CARD_RECKLESS_STRIKE = preload("res://data/card_reckless_strike.tres")
const CARD_MIND_CRUSH = preload("res://data/card_mind_crush.tres")
const CARD_FLURRY = preload("res://data/card_flurry.tres")
const CARD_GOLDEN_OPPORTUNITY = preload("res://data/card_golden_opportunity.tres")
const CARD_ALL_IN = preload("res://data/card_all_in.tres")
const CARD_DRAIN_LIFE = preload("res://data/card_drain_life.tres")
const CARD_PRECISE_STRIKE = preload("res://data/card_precise_strike.tres")

var all_characters: Array[CharacterData] = []
var selected_character: CharacterData = null
var player_xp: int = 0

# Bouquets (premium currency, persists between runs)
var total_bouquets: int = 0

# Skins system
var unlocked_skins: Array[String] = []  # Array of skin IDs
var selected_skins: Dictionary = {}  # character_name -> skin_id

# Available skins data (with preview textures)
const AVAILABLE_SKINS = {
	# Spring Collection
	# Note: Use .PNG (uppercase) to match actual filenames on case-sensitive filesystems (Android)
	"spring_chriswave": {
		"character": "Chriswave",
		"name": "Spring Chriswave",
		"cost": 150,
		"description": "Chriswave in a beautiful spring outfit with cherry blossoms.",
		"preview": "res://assets/skins/Chriswave_Spring.PNG",
		"collection": "spring"
	},
	"spring_gaechka": {
		"character": "Gaechka",
		"name": "Spring Gaechka",
		"cost": 150,
		"description": "Gaechka enjoying the warm spring breeze.",
		"preview": "res://assets/skins/Gaechka_Spring.PNG",
		"collection": "spring"
	},
	"spring_dangerlyoha": {
		"character": "Dangerlyoha",
		"name": "Spring Dangerlyoha",
		"cost": 150,
		"description": "Dangerlyoha surrounded by blooming flowers.",
		"preview": "res://assets/skins/Dangerlyoha_Spring.PNG",
		"collection": "spring"
	},
	# Goth Season Collection
	"goth_yuuechka": {
		"character": "Yuuechka",
		"name": "Goth Yuuechka",
		"cost": 200,
		"description": "Yuuechka embracing the dark aesthetic with gothic elegance.",
		"preview": "res://assets/skins/goth_yuuechka.PNG",
		"collection": "goth"
	},
	"goth_morpheya": {
		"character": "Morpheya",
		"name": "Goth Morpheya",
		"cost": 200,
		"description": "Morpheya in a mysterious gothic attire.",
		"preview": "res://assets/skins/goth_morpheya.PNG",
		"collection": "goth"
	},
}

func _ready() -> void:
	all_characters = [
		CHAR_TANK, CHAR_AGGRO, CHAR_CONTROL, CHAR_COMBO,
		CHAR_EVELONE, CHAR_BUSTER, CHAR_MOKRIVSKYI, CHAR_CHRISWAVE, CHAR_GAECHKA
	]
	_load_save_data()

func select_character(character: CharacterData) -> void:
	selected_character = character
	character_selected.emit(character)

func get_starting_deck(character: CharacterData) -> Array[CardData]:
	var deck: Array[CardData] = []

	# Add strikes
	for i in range(character.strike_count):
		deck.append(CARD_STRIKE.duplicate())

	# Add defends
	for i in range(character.defend_count):
		deck.append(CARD_DEFEND.duplicate())

	# Add character-specific cards
	match character.passive_type:
		CharacterData.PassiveType.START_WITH_BLOCK:
			# Tank gets 2 Iron Wall
			deck.append(CARD_IRON_WALL.duplicate())
			deck.append(CARD_IRON_WALL.duplicate())
		CharacterData.PassiveType.BONUS_ATTACK_DAMAGE:
			# Aggro gets 1 Rage
			deck.append(CARD_RAGE.duplicate())
		CharacterData.PassiveType.ENEMY_WEAKEN:
			# Control gets 2 Weaken
			deck.append(CARD_WEAKEN.duplicate())
			deck.append(CARD_WEAKEN.duplicate())
		CharacterData.PassiveType.COMBO_FREE_CARD:
			# Combo gets 2 Quick Draw
			deck.append(CARD_QUICK_DRAW.duplicate())
			deck.append(CARD_QUICK_DRAW.duplicate())
		CharacterData.PassiveType.GOLD_ON_DAMAGE:
			# Evelone gets 1 Rage (more damage = more gold)
			deck.append(CARD_RAGE.duplicate())
		CharacterData.PassiveType.CRIT_CHANCE:
			# Buster gets 2 Rage (maximize crit potential)
			deck.append(CARD_RAGE.duplicate())
			deck.append(CARD_RAGE.duplicate())
		CharacterData.PassiveType.LIFESTEAL:
			# Mokrivskyi gets 1 Rage (sustain through damage)
			deck.append(CARD_RAGE.duplicate())
		CharacterData.PassiveType.BONUS_ENERGY:
			# Chriswave gets 2 Quick Draw (use extra energy)
			deck.append(CARD_QUICK_DRAW.duplicate())
			deck.append(CARD_QUICK_DRAW.duplicate())
		CharacterData.PassiveType.DRAW_ON_KILL:
			# Gaechka gets 1 Quick Draw + 1 Rage (kill faster for draws)
			deck.append(CARD_QUICK_DRAW.duplicate())
			deck.append(CARD_RAGE.duplicate())

	return deck

func add_xp(amount: int) -> void:
	player_xp += amount
	_check_unlocks()
	_save_data()

func _check_unlocks() -> void:
	for character in all_characters:
		if not character.is_unlocked and player_xp >= character.unlock_cost:
			character.is_unlocked = true

# Bouquet functions
func add_bouquets(amount: int) -> void:
	total_bouquets += amount
	bouquets_changed.emit(total_bouquets)
	_save_data()

func spend_bouquets(amount: int) -> bool:
	if total_bouquets >= amount:
		total_bouquets -= amount
		bouquets_changed.emit(total_bouquets)
		_save_data()
		return true
	return false

func get_bouquets() -> int:
	return total_bouquets

# Skin functions
func unlock_skin(skin_id: String) -> bool:
	if skin_id in AVAILABLE_SKINS and skin_id not in unlocked_skins:
		var skin_data = AVAILABLE_SKINS[skin_id]
		if spend_bouquets(skin_data.cost):
			unlocked_skins.append(skin_id)
			skin_unlocked.emit(skin_id)
			_save_data()
			return true
	return false

func is_skin_unlocked(skin_id: String) -> bool:
	return skin_id in unlocked_skins

func select_skin(character_name: String, skin_id: String) -> void:
	if skin_id in unlocked_skins or skin_id == "default":
		selected_skins[character_name] = skin_id
		_save_data()

func get_selected_skin(character_name: String) -> String:
	return selected_skins.get(character_name, "default")

func get_all_skins_for_character(character_name: String) -> Array:
	var skins = [{"id": "default", "name": "Default", "cost": 0, "unlocked": true}]
	for skin_id in AVAILABLE_SKINS:
		var skin_data = AVAILABLE_SKINS[skin_id]
		if skin_data.character == character_name:
			skins.append({
				"id": skin_id,
				"name": skin_data.name,
				"cost": skin_data.cost,
				"unlocked": is_skin_unlocked(skin_id)
			})
	return skins

func _load_save_data() -> void:
	var save_path = "user://save_data.cfg"
	var config = ConfigFile.new()
	if config.load(save_path) == OK:
		player_xp = config.get_value("progress", "xp", 0)
		total_bouquets = config.get_value("progress", "bouquets", 0)

		# Load skins
		var saved_skins = config.get_value("skins", "unlocked", [])
		unlocked_skins.clear()
		for skin in saved_skins:
			unlocked_skins.append(skin)

		var saved_selected = config.get_value("skins", "selected", {})
		selected_skins = saved_selected

		_check_unlocks()

func _save_data() -> void:
	var save_path = "user://save_data.cfg"
	var config = ConfigFile.new()
	config.set_value("progress", "xp", player_xp)
	config.set_value("progress", "bouquets", total_bouquets)
	config.set_value("skins", "unlocked", unlocked_skins)
	config.set_value("skins", "selected", selected_skins)
	config.save(save_path)
