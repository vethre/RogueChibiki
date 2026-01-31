extends Node

# Singleton for managing a single run

signal run_started
signal encounter_completed
signal run_ended(victory: bool)
signal floor_changed(floor_num: int)
signal stage_changed(stage_num: int)
signal run_completed  # Fired when main run is beaten
signal infinite_mode_started
signal relic_acquired(relic: RelicData)
signal relic_broken(relic: RelicData)
signal bouquets_changed(amount: int)
signal consumable_changed(slot: int, consumable)

enum EncounterType { COMBAT, ELITE, SHOP, REST, BOSS, EVENT }

# Boss effects (like Balatro Boss Blinds)
enum BossEffect {
	NONE,
	REDUCED_ENERGY,    # -1 energy per turn
	REDUCED_HAND,      # -2 cards drawn per turn
	DEBUFFED_ATTACKS,  # Attack cards deal -2 damage
	WEAKENED_DEFENSE,  # Defend cards give -2 block
	ENEMY_REGEN,       # Boss heals 5 HP per turn
	PLAYER_BURN,       # Player takes 2 damage per turn
	NO_BLOCK_START,    # Can't gain block first turn
	SHUFFLED_HAND,     # Cards cost random energy (1-3)
}

const BOSS_EFFECT_NAMES = {
	BossEffect.NONE: "Standard Boss",
	BossEffect.REDUCED_ENERGY: "Energy Drain",
	BossEffect.REDUCED_HAND: "Limited Vision",
	BossEffect.DEBUFFED_ATTACKS: "Armored",
	BossEffect.WEAKENED_DEFENSE: "Shield Breaker",
	BossEffect.ENEMY_REGEN: "Regenerating",
	BossEffect.PLAYER_BURN: "Burning Aura",
	BossEffect.NO_BLOCK_START: "Ambush",
	BossEffect.SHUFFLED_HAND: "Chaos",
}

const BOSS_EFFECT_DESCRIPTIONS = {
	BossEffect.NONE: "No special effect",
	BossEffect.REDUCED_ENERGY: "-1 energy per turn",
	BossEffect.REDUCED_HAND: "-2 cards drawn per turn",
	BossEffect.DEBUFFED_ATTACKS: "Attack cards deal -2 damage",
	BossEffect.WEAKENED_DEFENSE: "Defend cards give -2 block",
	BossEffect.ENEMY_REGEN: "Boss heals 5 HP each turn",
	BossEffect.PLAYER_BURN: "Take 2 damage each turn",
	BossEffect.NO_BLOCK_START: "Can't block first turn",
	BossEffect.SHUFFLED_HAND: "Card costs randomized (1-3)",
}

var current_boss_effect: BossEffect = BossEffect.NONE

# Run state
var is_run_active: bool = false
var current_floor: int = 0

# Stage system (every 3 combats = 1 stage, then shop)
var current_stage: int = 1
var combats_in_stage: int = 0
const COMBATS_PER_STAGE: int = 3
const BOSS_EVERY_STAGES: int = 5  # Boss every 5 stages
const FINAL_STAGE: int = 10  # Main run ends at stage 10 (2 boss fights)

# Infinite mode milestone titles (Balatro-style)
const INFINITE_MILESTONES = {
	15: "Brave",
	20: "Bold",
	25: "Relentless",
	30: "Unstoppable",
	40: "Legendary",
	50: "Mythical",
	69: "Nice",
	75: "Transcendent",
	100: "Ascended",
	150: "Godlike",
	200: "Beyond Mortal",
	250: "Reality Breaker",
	300: "Void Walker",
	400: "Time Defier",
	500: "Infinity Seeker",
	666: "Cursed One",
	777: "Lucky Seven",
	999: "Edge of Existence",
	1000: "THE CHIBIKI",
	1337: "L33T",
	2000: "nanechibiki",
	5000: "???",
	9999: "END OF DATA",
}

# Run mode
var is_infinite_mode: bool = false
var main_run_completed: bool = false

# Seed system (Balatro-style)
var run_seed: String = ""
var is_seeded_run: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Player run state
var run_hp: int = 50
var run_max_hp: int = 50
var run_gold: int = 50
var run_deck: Array[CardData] = []
var run_relics: Array[RelicData] = []
var run_bouquets: int = 0

# Consumables system (2 slots)
const MAX_CONSUMABLE_SLOTS: int = 2
var run_consumables: Array = []  # Array of ConsumableData or null

# All available relics (loaded on ready)
var all_relics: Array[RelicData] = []

# All available consumables (loaded on ready)
var all_consumables: Array = []

# Player upgrades (permanent for this run)
var bonus_energy: int = 0
var bonus_draw: int = 0
var bonus_damage: int = 0
var bonus_block: int = 0
var gold_multiplier: float = 1.0
var heal_on_kill: int = 0

# Stats for this run
var enemies_defeated: int = 0
var damage_dealt: int = 0
var damage_taken: int = 0
var cards_played: int = 0
var attack_cards_played: int = 0
var defend_cards_played: int = 0
var gold_earned: int = 0
var gold_spent: int = 0

# Run Score (IEEE standard - finite, stable representation)
var run_score: int = 0

# Encounter schedule (dynamic)
var current_encounter: EncounterType = EncounterType.COMBAT

# Difficulty scaling - GRADUAL (logarithmic growth)
var difficulty_multiplier: float = 1.0
const BASE_DIFFICULTY_GROWTH: float = 0.08  # 8% growth per stage (not floor)

func _ready() -> void:
	_load_relics()
	_load_consumables()

func _load_relics() -> void:
	# Load all relic resources
	var relic_dir = "res://data/relics/"
	var dir = DirAccess.open(relic_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var relic = load(relic_dir + file_name) as RelicData
				if relic:
					all_relics.append(relic)
			file_name = dir.get_next()
		dir.list_dir_end()

func _load_consumables() -> void:
	# Load all consumable resources
	var consumable_dir = "res://data/consumables/"
	var dir = DirAccess.open(consumable_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var consumable = load(consumable_dir + file_name)
				if consumable:
					all_consumables.append(consumable)
			file_name = dir.get_next()
		dir.list_dir_end()

func start_new_run(character: CharacterData, custom_seed: String = "") -> void:
	is_run_active = true
	current_floor = 0
	current_stage = 1
	combats_in_stage = 0
	is_infinite_mode = false
	main_run_completed = false

	# Setup seed system
	if custom_seed != "":
		# Seeded run - use provided seed
		run_seed = custom_seed.to_upper()
		is_seeded_run = true
	else:
		# Unseeded run - generate random seed
		run_seed = _generate_random_seed()
		is_seeded_run = false

	# Initialize RNG with seed
	rng.seed = hash(run_seed)

	# Setup from character
	run_max_hp = character.starting_hp
	run_hp = run_max_hp
	run_gold = 75  # Increased from 50 for better early shop access
	run_deck = GameManager.get_starting_deck(character)
	run_relics = []
	run_bouquets = 0
	run_consumables = [null, null]  # Initialize 2 empty slots

	# Reset upgrades
	bonus_energy = 0
	bonus_draw = 0
	bonus_damage = 0
	bonus_block = 0
	gold_multiplier = 1.0
	heal_on_kill = 0

	# Reset stats
	enemies_defeated = 0
	damage_dealt = 0
	damage_taken = 0
	cards_played = 0
	attack_cards_played = 0
	defend_cards_played = 0
	gold_earned = 0
	gold_spent = 0
	difficulty_multiplier = 1.0
	run_score = 0

	run_started.emit()
	_go_to_next_encounter()

func _generate_random_seed() -> String:
	"""Generate a random 8-character alphanumeric seed."""
	var chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # No I, O, 0, 1 to avoid confusion
	var seed_str = ""
	for i in range(8):
		seed_str += chars[randi() % chars.length()]
	return seed_str

func get_run_seed() -> String:
	return run_seed

func is_run_seeded() -> bool:
	return is_seeded_run

func seeded_randf() -> float:
	"""Get a seeded random float (0.0 to 1.0)."""
	return rng.randf()

func seeded_randi_range(from: int, to: int) -> int:
	"""Get a seeded random integer in range."""
	return rng.randi_range(from, to)

func seeded_randf_range(from: float, to: float) -> float:
	"""Get a seeded random float in range."""
	return rng.randf_range(from, to)

func _determine_next_encounter() -> EncounterType:
	# After 3 combats in stage, go to shop and advance stage
	if combats_in_stage >= COMBATS_PER_STAGE:
		combats_in_stage = 0
		current_stage += 1
		stage_changed.emit(current_stage)
		return EncounterType.SHOP

	# Check if this is the LAST combat (3rd) of a boss stage
	# Bosses appear as the final enemy of stages 5, 10, 15, etc.
	if combats_in_stage == COMBATS_PER_STAGE - 1:  # About to be 3rd combat
		if current_stage >= BOSS_EVERY_STAGES and current_stage % BOSS_EVERY_STAGES == 0:
			_select_boss_effect()  # Choose a random boss effect
			return EncounterType.BOSS

	# Event chance disabled - keep clean 3-enemy-shop pattern
	# Events can still appear from other sources (shops, relics, etc.)
	# var event_chance = 0.15
	# if current_floor > 1 and combats_in_stage > 0 and seeded_randf() < event_chance:
	#	return EncounterType.EVENT

	# Elite chance increases with stage (reduced early game)
	# No elites in stage 1, then 5% + 3% per stage after that
	# Elites don't appear on the 3rd combat of boss stages (boss takes that slot)
	var elite_chance = 0.0
	if current_stage >= 2:
		elite_chance = 0.05 + (current_stage - 2) * 0.03
	elite_chance = min(elite_chance, 0.25)  # Cap at 25%

	# In infinite mode, elite chance is higher
	if is_infinite_mode:
		elite_chance += 0.10

	if seeded_randf() < elite_chance and combats_in_stage > 0:
		return EncounterType.ELITE

	return EncounterType.COMBAT

func get_current_encounter_type() -> EncounterType:
	return current_encounter

func get_current_boss_effect() -> BossEffect:
	return current_boss_effect

func get_boss_effect_name() -> String:
	return BOSS_EFFECT_NAMES.get(current_boss_effect, "Unknown")

func get_boss_effect_description() -> String:
	return BOSS_EFFECT_DESCRIPTIONS.get(current_boss_effect, "")

func _select_boss_effect() -> void:
	"""Select a random boss effect for the current boss encounter."""
	var effects = [
		BossEffect.REDUCED_ENERGY,
		BossEffect.REDUCED_HAND,
		BossEffect.DEBUFFED_ATTACKS,
		BossEffect.WEAKENED_DEFENSE,
		BossEffect.ENEMY_REGEN,
		BossEffect.PLAYER_BURN,
		BossEffect.NO_BLOCK_START,
		BossEffect.SHUFFLED_HAND,
	]

	# First boss (stage 5) has a 50% chance of no effect to ease players in
	if current_stage <= BOSS_EVERY_STAGES:
		if seeded_randf() < 0.5:
			current_boss_effect = BossEffect.NONE
			return

	current_boss_effect = effects[seeded_randi_range(0, effects.size() - 1)]

func reset_boss_effect() -> void:
	current_boss_effect = BossEffect.NONE

func complete_encounter(victory: bool, hp_remaining: int, gold_reward: int = 0) -> void:
	if not victory:
		_end_run(false)
		return

	run_hp = hp_remaining

	# Apply gold multiplier
	var actual_gold = int(gold_reward * gold_multiplier)
	run_gold += actual_gold
	gold_earned += actual_gold

	# Apply heal on kill and track stats
	if current_encounter in [EncounterType.COMBAT, EncounterType.ELITE, EncounterType.BOSS]:
		enemies_defeated += 1
		combats_in_stage += 1
		if heal_on_kill > 0:
			run_hp = min(run_hp + heal_on_kill, run_max_hp)

		# Add score based on encounter type
		_add_encounter_score(current_encounter)

	# Check if final boss was defeated (main run complete)
	if current_encounter == EncounterType.BOSS and current_stage >= FINAL_STAGE and not main_run_completed:
		main_run_completed = true
		run_completed.emit()
		# Player can choose to continue to infinite mode or end
		return  # Wait for player choice

	encounter_completed.emit()
	_go_to_next_encounter()

func continue_to_infinite_mode() -> void:
	"""Called when player chooses to continue after beating main run."""
	is_infinite_mode = true
	infinite_mode_started.emit()

	# Bonus for entering infinite mode
	run_score += 10000

	encounter_completed.emit()
	_go_to_next_encounter()

var combat_damage_taken_this_fight: int = 0

func reset_combat_damage_tracker() -> void:
	combat_damage_taken_this_fight = 0

func add_combat_damage_taken(amount: int) -> void:
	combat_damage_taken_this_fight += amount

func _add_encounter_score(encounter: EncounterType) -> void:
	"""Add score based on encounter completed."""
	var base_score = 0
	match encounter:
		EncounterType.COMBAT:
			base_score = 100
		EncounterType.ELITE:
			base_score = 300
		EncounterType.BOSS:
			base_score = 1000

	# Bonus for HP remaining (efficiency bonus)
	var hp_percent = float(run_hp) / float(run_max_hp)
	var efficiency_bonus = int(base_score * hp_percent * 0.5)

	# Perfect combat bonus (took no damage)
	var perfect_bonus = 0
	if combat_damage_taken_this_fight == 0:
		perfect_bonus = base_score  # Double score for perfect!

	# Stage multiplier (higher stages = more score)
	var stage_multiplier = 1.0 + (current_stage - 1) * 0.1

	# Infinite mode multiplier
	if is_infinite_mode:
		stage_multiplier *= 1.5

	run_score += int((base_score + efficiency_bonus + perfect_bonus) * stage_multiplier)

func _go_to_next_encounter() -> void:
	current_floor += 1
	floor_changed.emit(current_floor)

	# GRADUAL difficulty scaling (linear per stage, not exponential per floor)
	difficulty_multiplier = 1.0 + (current_stage - 1) * BASE_DIFFICULTY_GROWTH

	# Determine next encounter type dynamically
	current_encounter = _determine_next_encounter()

	match current_encounter:
		EncounterType.COMBAT, EncounterType.ELITE, EncounterType.BOSS:
			get_tree().change_scene_to_file("res://scenes/combat/combat_scene.tscn")
		EncounterType.SHOP:
			get_tree().change_scene_to_file("res://scenes/shop/shop_scene.tscn")
		EncounterType.REST:
			get_tree().change_scene_to_file("res://scenes/rest/rest_scene.tscn")
		EncounterType.EVENT:
			get_tree().change_scene_to_file("res://scenes/event/event_scene.tscn")

func end_run_with_victory() -> void:
	"""Called when player beats main run and chooses to end."""
	_end_run(true)

func _end_run(victory: bool) -> void:
	is_run_active = false

	# Calculate XP earned
	var xp_earned = _calculate_xp()
	GameManager.add_xp(xp_earned)

	# Calculate bouquets earned
	var bouquets_earned = _calculate_bouquets(victory)
	run_bouquets += bouquets_earned
	GameManager.add_bouquets(run_bouquets)

	# Record stats with score
	# If player completed main run, count as victory even if they died in infinite mode
	var final_victory = victory or main_run_completed
	StatsManager.record_run(final_victory, current_floor, enemies_defeated, damage_dealt,
		attack_cards_played, defend_cards_played, run_score)

	run_ended.emit(victory)

func _calculate_bouquets(victory: bool) -> int:
	var bouquets = 0

	# Base bouquets: 1 per floor reached
	bouquets += current_floor

	# Bonus for enemies defeated
	bouquets += enemies_defeated / 3

	# Victory bonus
	if victory:
		bouquets += 10

	# Main run completion bonus
	if main_run_completed:
		bouquets += 25

	# Infinite mode bonus
	if is_infinite_mode:
		bouquets += (current_stage - FINAL_STAGE) * 5

	return bouquets

func _calculate_xp() -> int:
	var xp = 0
	xp += current_floor * 10  # 10 XP per floor
	xp += enemies_defeated * 15  # 15 XP per enemy

	# Bonus for completing main run
	if main_run_completed:
		xp += 500

	# Extra bonus for infinite mode progress
	if is_infinite_mode:
		xp += (current_stage - FINAL_STAGE) * 50

	return xp

func add_card_to_deck(card: CardData) -> void:
	run_deck.append(card)

func remove_card_from_deck(index: int) -> void:
	if index >= 0 and index < run_deck.size():
		run_deck.remove_at(index)

func heal(amount: int) -> void:
	run_hp = min(run_hp + amount, run_max_hp)

func spend_gold(amount: int) -> bool:
	if run_gold >= amount:
		run_gold -= amount
		gold_spent += amount
		return true
	return false

func record_card_played(card_type: CardData.CardType) -> void:
	cards_played += 1
	if card_type == CardData.CardType.ATTACK:
		attack_cards_played += 1
	elif card_type == CardData.CardType.DEFEND:
		defend_cards_played += 1

func record_damage(dealt: int, taken: int) -> void:
	damage_dealt += dealt
	damage_taken += taken

func get_enemy_hp_for_floor() -> int:
	# Base HP: 18 + 3 per stage (slower scaling)
	var base_hp = 18 + current_stage * 3
	var encounter_type = get_current_encounter_type()

	match encounter_type:
		EncounterType.ELITE:
			base_hp = int(base_hp * 1.5)  # Reduced from 1.8x
		EncounterType.BOSS:
			base_hp = int(base_hp * 2.2)  # Reduced from 3.0x

	return int(base_hp * difficulty_multiplier)

func get_enemy_damage_for_floor() -> Vector2i:
	# Damage: 4-7 base, +1/+1 per stage (slower scaling)
	var base_min = 4 + int(current_stage * 0.5)
	var base_max = 7 + current_stage
	var encounter_type = get_current_encounter_type()

	match encounter_type:
		EncounterType.ELITE:
			base_min = int(base_min * 1.3)  # Reduced from 1.5x
			base_max = int(base_max * 1.3)
		EncounterType.BOSS:
			base_min = int(base_min * 1.6)  # Reduced from 2.0x
			base_max = int(base_max * 1.6)

	return Vector2i(
		int(base_min * difficulty_multiplier),
		int(base_max * difficulty_multiplier)
	)

func get_gold_reward() -> int:
	# Increased base gold: 15 + 4 per stage
	var base_gold = 15 + current_stage * 4
	var encounter_type = get_current_encounter_type()

	match encounter_type:
		EncounterType.ELITE:
			base_gold = int(base_gold * 2.5)  # Better elite rewards
		EncounterType.BOSS:
			base_gold = int(base_gold * 4.0)  # Better boss rewards

	return int(base_gold * seeded_randf_range(0.9, 1.15))

# Upgrade functions
func add_upgrade(upgrade_type: String, value: int) -> void:
	match upgrade_type:
		"energy":
			bonus_energy += value
		"draw":
			bonus_draw += value
		"damage":
			bonus_damage += value
		"block":
			bonus_block += value
		"max_hp":
			run_max_hp += value
			run_hp += value
		"heal_on_kill":
			heal_on_kill += value
		"gold":
			gold_multiplier += value * 0.1

func get_bonus_energy() -> int:
	return bonus_energy

func get_bonus_draw() -> int:
	return bonus_draw

func get_bonus_damage() -> int:
	return bonus_damage

func get_bonus_block() -> int:
	return bonus_block

func get_run_score() -> int:
	return run_score

func is_main_run_completed() -> bool:
	return main_run_completed

func is_in_infinite_mode() -> bool:
	return is_infinite_mode

func get_infinite_milestone() -> String:
	"""Returns the milestone title for current stage in infinite mode."""
	if not is_infinite_mode:
		return ""

	var milestone_title = ""
	var highest_reached = 0

	for milestone_stage in INFINITE_MILESTONES.keys():
		if current_stage >= milestone_stage and milestone_stage > highest_reached:
			highest_reached = milestone_stage
			milestone_title = INFINITE_MILESTONES[milestone_stage]

	return milestone_title

func get_stage_display_name() -> String:
	"""Returns stage with milestone title if in infinite mode."""
	var milestone = get_infinite_milestone()
	if milestone != "":
		return "Stage %d [%s]" % [current_stage, milestone]
	return "Stage %d" % current_stage

# Relic functions
func add_relic(relic: RelicData) -> void:
	run_relics.append(relic)
	_apply_relic_effect(relic)
	relic_acquired.emit(relic)

func _apply_relic_effect(relic: RelicData) -> void:
	match relic.effect_type:
		RelicData.RelicEffect.BONUS_DAMAGE:
			bonus_damage += relic.effect_value
		RelicData.RelicEffect.BONUS_BLOCK:
			bonus_block += relic.effect_value
		RelicData.RelicEffect.BONUS_GOLD:
			gold_multiplier += relic.effect_value * 0.01
		RelicData.RelicEffect.HEAL_ON_KILL:
			heal_on_kill += relic.effect_value
		RelicData.RelicEffect.BONUS_DRAW:
			bonus_draw += relic.effect_value
		RelicData.RelicEffect.MAX_HP_BONUS:
			run_max_hp += relic.effect_value
			run_hp += relic.effect_value

func get_relics() -> Array[RelicData]:
	return run_relics

func has_relic(relic_name: String) -> bool:
	for relic in run_relics:
		if relic.relic_name == relic_name:
			return true
	return false

func get_relic_bonus(effect_type: RelicData.RelicEffect) -> int:
	var bonus = 0
	for relic in run_relics:
		if relic.effect_type == effect_type:
			bonus += relic.effect_value
	return bonus

func get_random_relic(exclude_owned: bool = true) -> RelicData:
	var available = all_relics.duplicate()
	if exclude_owned:
		for owned in run_relics:
			available.erase(owned)
	if available.size() > 0:
		return available[seeded_randi_range(0, available.size() - 1)]
	return null

func check_relic_breakage() -> Array[RelicData]:
	"""Check if any relics break after combat. Returns list of broken relics."""
	var broken: Array[RelicData] = []

	# Base break chance is very low (balancing)
	const BASE_BREAK_CHANCE: float = 3.0  # 3% base chance for fragile relics

	for relic in run_relics.duplicate():  # Duplicate to safely modify during iteration
		if relic.is_fragile:
			var break_roll = seeded_randf() * 100.0
			var total_chance = BASE_BREAK_CHANCE + relic.break_chance

			if break_roll < total_chance:
				broken.append(relic)
				_remove_relic(relic)

	return broken

func _remove_relic(relic: RelicData) -> void:
	"""Remove a relic and reverse its effects."""
	if relic not in run_relics:
		return

	# Reverse the relic's effect
	match relic.effect_type:
		RelicData.RelicEffect.BONUS_DAMAGE:
			bonus_damage -= relic.effect_value
		RelicData.RelicEffect.BONUS_BLOCK:
			bonus_block -= relic.effect_value
		RelicData.RelicEffect.BONUS_GOLD:
			gold_multiplier -= relic.effect_value * 0.01
		RelicData.RelicEffect.HEAL_ON_KILL:
			heal_on_kill -= relic.effect_value
		RelicData.RelicEffect.BONUS_DRAW:
			bonus_draw -= relic.effect_value
		RelicData.RelicEffect.MAX_HP_BONUS:
			run_max_hp -= relic.effect_value
			run_hp = min(run_hp, run_max_hp)

	run_relics.erase(relic)
	relic_broken.emit(relic)

# Bouquet functions
func add_bouquets(amount: int) -> void:
	run_bouquets += amount
	bouquets_changed.emit(run_bouquets)

func get_bouquets() -> int:
	return run_bouquets

# Consumable functions
func add_consumable(consumable) -> bool:
	"""Add a consumable to the first available slot. Returns true if successful."""
	for i in range(MAX_CONSUMABLE_SLOTS):
		if run_consumables[i] == null:
			run_consumables[i] = consumable
			consumable_changed.emit(i, consumable)
			return true
	return false  # No empty slots

func remove_consumable(slot: int) -> void:
	"""Remove consumable from a slot."""
	if slot >= 0 and slot < MAX_CONSUMABLE_SLOTS:
		run_consumables[slot] = null
		consumable_changed.emit(slot, null)

func get_consumable(slot: int):
	"""Get consumable at slot."""
	if slot >= 0 and slot < MAX_CONSUMABLE_SLOTS:
		return run_consumables[slot]
	return null

func has_empty_consumable_slot() -> bool:
	"""Check if there's room for a new consumable."""
	for i in range(MAX_CONSUMABLE_SLOTS):
		if run_consumables[i] == null:
			return true
	return false

func get_consumables() -> Array:
	"""Get all consumable slots."""
	return run_consumables

func get_random_consumable():
	"""Get a random consumable from the pool."""
	if all_consumables.size() > 0:
		return all_consumables[seeded_randi_range(0, all_consumables.size() - 1)]
	return null

# Card upgrade function
func upgrade_card(card_index: int) -> bool:
	if card_index >= 0 and card_index < run_deck.size():
		var card = run_deck[card_index]
		if not card.is_upgraded:
			card.upgrade()
			return true
	return false

func get_upgradeable_cards() -> Array[int]:
	var indices: Array[int] = []
	for i in range(run_deck.size()):
		if not run_deck[i].is_upgraded:
			indices.append(i)
	return indices
