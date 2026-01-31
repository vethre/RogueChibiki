extends Node
class_name CombatManager

signal combat_ended(player_won: bool)
signal turn_changed(is_player_turn: bool)
signal player_stats_changed
signal enemy_stats_changed
signal damage_dealt(target: String, amount: int)
signal block_gained(target: String, amount: int)
signal card_effect_triggered(effect: String)
signal gold_earned(amount: int)

enum CombatState { PLAYER_TURN, ENEMY_TURN, COMBAT_OVER }

# Character reference
var character: CharacterData

# Player stats
var player_hp: int = 50
var player_max_hp: int = 50
var player_block: int = 0
var player_energy: int = 3
var player_max_energy: int = 3

# Enemy stats
var enemy_hp: int = 30
var enemy_max_hp: int = 30
var enemy_block: int = 0
var enemy_damage: int = 8
var enemy_intent: String = "attack"
var enemy_weakened: int = 0

# Special effect tracking
var fortify_block: int = 0
var pending_draw_on_kill: bool = false

# Boss effect tracking
var is_first_turn: bool = true
var boss_effect_active: bool = false

# Deck management
var deck: Array[CardData] = []
var discard_pile: Array[CardData] = []
var draw_pile: Array[CardData] = []

var current_state: CombatState = CombatState.PLAYER_TURN
var cards_to_draw: int = 5
var cards_played_this_turn: int = 0

# Is this part of a run?
var is_run_combat: bool = false
var gold_reward: int = 0

signal hand_selection_changed(selected_count: int, total_cost: int)

@onready var hand: Hand = $"../Hand"

func _ready() -> void:
	hand.card_played.connect(_on_card_played)
	hand.selection_changed.connect(_on_selection_changed)

func _on_selection_changed(selected_cards: Array[Card]) -> void:
	var total_cost = hand.get_total_selected_cost()
	hand_selection_changed.emit(selected_cards.size(), total_cost)

func start_combat(char_data: CharacterData) -> void:
	character = char_data

	# Reset perfect combat tracker
	RunManager.reset_combat_damage_tracker()

	# Reset boss effect tracking
	is_first_turn = true
	boss_effect_active = false

	# Check if this is part of an active run
	is_run_combat = RunManager.is_run_active

	if is_run_combat:
		# Use run state
		player_max_hp = RunManager.run_max_hp
		player_hp = RunManager.run_hp
		deck = RunManager.run_deck.duplicate()
		gold_reward = RunManager.get_gold_reward()

		# Get enemy stats from run manager (difficulty scaled)
		enemy_max_hp = RunManager.get_enemy_hp_for_floor()
		var dmg_range = RunManager.get_enemy_damage_for_floor()
		enemy_damage = randi_range(dmg_range.x, dmg_range.y)

		# Check if this is a boss encounter with an effect
		if RunManager.get_current_encounter_type() == RunManager.EncounterType.BOSS:
			boss_effect_active = RunManager.get_current_boss_effect() != RunManager.BossEffect.NONE
	else:
		# Standalone combat (for testing)
		player_max_hp = character.starting_hp
		player_hp = player_max_hp
		deck = GameManager.get_starting_deck(character)
		enemy_max_hp = randi_range(25, 40)
		gold_reward = 20

	player_max_energy = character.starting_energy
	player_block = 0
	enemy_hp = enemy_max_hp
	enemy_block = 0
	enemy_weakened = 0

	# Apply pre-combat weaken from shop items
	if RunManager.next_enemy_weakened > 0:
		enemy_weakened = RunManager.next_enemy_weakened
		RunManager.next_enemy_weakened = 0

	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()

	_apply_start_of_combat_passive()
	_start_player_turn()

func _apply_start_of_combat_passive() -> void:
	match character.passive_type:
		CharacterData.PassiveType.START_WITH_BLOCK:
			player_block = character.passive_value
			block_gained.emit("player", character.passive_value)
		CharacterData.PassiveType.ENEMY_WEAKEN:
			enemy_weakened = 1
		CharacterData.PassiveType.BONUS_ENERGY:
			# Extra energy is applied at turn start
			pass

func _start_player_turn() -> void:
	current_state = CombatState.PLAYER_TURN
	player_block = 0

	# Apply fortify block from previous turn
	if fortify_block > 0:
		player_block = fortify_block
		block_gained.emit("player", fortify_block)
		fortify_block = 0

	player_energy = player_max_energy + RunManager.get_bonus_energy()

	# Chriswave passive: bonus energy each turn
	if character.passive_type == CharacterData.PassiveType.BONUS_ENERGY:
		player_energy += character.passive_value

	# Apply boss effects
	if boss_effect_active:
		_apply_boss_effect_start_turn()

	cards_played_this_turn = 0

	var draw_count = cards_to_draw + RunManager.get_bonus_draw()

	# Boss effect: reduced hand
	if boss_effect_active and RunManager.get_current_boss_effect() == RunManager.BossEffect.REDUCED_HAND:
		draw_count = max(1, draw_count - 2)

	_draw_cards(draw_count)
	_decide_enemy_intent()

	is_first_turn = false
	turn_changed.emit(true)
	player_stats_changed.emit()
	enemy_stats_changed.emit()

func _apply_boss_effect_start_turn() -> void:
	var effect = RunManager.get_current_boss_effect()

	match effect:
		RunManager.BossEffect.REDUCED_ENERGY:
			player_energy = max(0, player_energy - 1)
			card_effect_triggered.emit("-1 ENERGY!")
		RunManager.BossEffect.PLAYER_BURN:
			var burn_damage = 2
			player_hp -= burn_damage
			damage_dealt.emit("player", burn_damage)
			card_effect_triggered.emit("BURN! -%d" % burn_damage)
		RunManager.BossEffect.NO_BLOCK_START:
			if is_first_turn:
				player_block = 0
				fortify_block = 0
				card_effect_triggered.emit("AMBUSH!")
		RunManager.BossEffect.ENEMY_REGEN:
			if not is_first_turn:  # Don't heal on first turn
				var heal_amount = min(5, enemy_max_hp - enemy_hp)
				if heal_amount > 0:
					enemy_hp += heal_amount
					card_effect_triggered.emit("BOSS HEALS +%d" % heal_amount)

func get_boss_damage_modifier() -> int:
	"""Get damage modifier from boss effect."""
	if boss_effect_active and RunManager.get_current_boss_effect() == RunManager.BossEffect.DEBUFFED_ATTACKS:
		return -2
	return 0

func get_boss_block_modifier() -> int:
	"""Get block modifier from boss effect."""
	if boss_effect_active and RunManager.get_current_boss_effect() == RunManager.BossEffect.WEAKENED_DEFENSE:
		return -2
	return 0

const MAX_HAND_SIZE: int = 10

func _draw_cards(count: int) -> void:
	for i in range(count):
		# Don't draw if hand is full
		if hand.get_card_count() >= MAX_HAND_SIZE:
			break
		if draw_pile.is_empty():
			_shuffle_discard_into_draw()
		if not draw_pile.is_empty():
			var card = draw_pile.pop_back()
			hand.add_card(card)

	hand.update_playable_cards(player_energy)

	# Check for auto-end turn after drawing
	await get_tree().process_frame
	_check_auto_end_turn()

func _shuffle_discard_into_draw() -> void:
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()

func _on_card_played(card_data: CardData) -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	var energy_cost = card_data.get_effective_cost()

	# Combo passive
	if character.passive_type == CharacterData.PassiveType.COMBO_FREE_CARD:
		if (cards_played_this_turn + 1) % character.passive_value == 0:
			energy_cost = 0
			card_effect_triggered.emit("FREE CARD!")

	if player_energy < energy_cost:
		return

	player_energy -= energy_cost
	cards_played_this_turn += 1

	# Track stats
	RunManager.record_card_played(card_data.card_type)

	# Calculate damage with bonuses (use effective values for upgrades)
	var damage = card_data.get_effective_damage()
	if damage > 0:
		damage += RunManager.get_bonus_damage()
		if character.passive_type == CharacterData.PassiveType.BONUS_ATTACK_DAMAGE:
			damage += character.passive_value
		# Apply boss effect modifier
		damage = max(0, damage + get_boss_damage_modifier())

	# Calculate block with bonuses (use effective values for upgrades)
	var block_amount = card_data.get_effective_block()
	if block_amount > 0:
		block_amount += RunManager.get_bonus_block()
		# Apply boss effect modifier
		block_amount = max(0, block_amount + get_boss_block_modifier())

	# Pre-set draw_on_kill before damage (so it triggers on this attack)
	if card_data.special_effect == "draw_on_kill":
		pending_draw_on_kill = true

	# Apply effects
	match card_data.card_type:
		CardData.CardType.ATTACK:
			_deal_damage_to_enemy(damage)
		CardData.CardType.DEFEND:
			player_block += block_amount
			block_gained.emit("player", block_amount)
			player_stats_changed.emit()

	# Special effects
	if card_data.special_effect == "weaken_2":
		enemy_weakened += 2
		card_effect_triggered.emit("WEAKENED!")
	elif card_data.special_effect == "gain_energy_2":
		var energy_gain = 2 if not card_data.is_upgraded else 3
		player_energy += energy_gain
		card_effect_triggered.emit("+%d ENERGY!" % energy_gain)
	elif card_data.special_effect == "fortify":
		var next_block = 5 if not card_data.is_upgraded else 8
		fortify_block += next_block
		card_effect_triggered.emit("FORTIFIED!")
	elif card_data.special_effect == "self_damage_4":
		var self_dmg = 4
		player_hp -= self_dmg
		damage_dealt.emit("player", self_dmg)
		card_effect_triggered.emit("-%d HP" % self_dmg)
	elif card_data.special_effect == "weaken_3_attack":
		enemy_weakened += 3
		_deal_damage_to_enemy(damage)
		card_effect_triggered.emit("WEAKENED!")
	elif card_data.special_effect == "multi_hit_3":
		# First hit already dealt above if card_type is ATTACK
		# Deal 2 more hits
		_deal_damage_to_enemy(damage)
		_deal_damage_to_enemy(damage)
		card_effect_triggered.emit("x3 HITS!")
	elif card_data.special_effect == "gain_gold_8":
		var gold_gain = 8 if not card_data.is_upgraded else 12
		RunManager.run_gold += gold_gain
		gold_earned.emit(gold_gain)
		card_effect_triggered.emit("+%d GOLD!" % gold_gain)
	# draw_on_kill is handled before damage dealing

	# Card goes to discard FIRST (before drawing) to ensure proper shuffle behavior
	discard_pile.append(card_data)

	# Draw extra cards (use effective value for upgrades)
	var draw_count = card_data.get_effective_draw()
	if draw_count > 0:
		_draw_cards(draw_count)

	hand.update_playable_cards(player_energy)
	player_stats_changed.emit()

	_check_combat_end()

	# Auto-end turn check
	if current_state == CombatState.PLAYER_TURN:
		await get_tree().process_frame
		_check_auto_end_turn()

func _check_auto_end_turn() -> void:
	if not StatsManager.auto_end_turn:
		return
	if current_state != CombatState.PLAYER_TURN:
		return

	# Auto-end if no energy OR no playable cards
	var has_playable = false
	for card in hand.cards:
		if card.card_data.get_effective_cost() <= player_energy:
			has_playable = true
			break

	if player_energy == 0 or (not has_playable and hand.cards.size() > 0):
		await get_tree().create_timer(0.3).timeout
		if current_state == CombatState.PLAYER_TURN:
			end_player_turn()

func can_play_selected_cards() -> bool:
	"""Check if the currently selected cards can be played."""
	if current_state != CombatState.PLAYER_TURN:
		return false
	var selected = hand.get_selected_cards()
	if selected.is_empty():
		return false
	var total_cost = hand.get_total_selected_cost()
	return player_energy >= total_cost

func play_selected_hand() -> void:
	"""Play all selected cards at once (Balatro-style Play Hand)."""
	if not can_play_selected_cards():
		return

	var selected = hand.get_selected_cards()
	if selected.is_empty():
		return

	# IMPORTANT: Duplicate the array before iterating!
	# remove_card() modifies selected_cards, which would skip cards during iteration
	var cards_to_play = selected.duplicate()

	# Calculate total cost before playing
	var total_cost = hand.get_total_selected_cost()

	# Deduct energy once for all cards
	player_energy -= total_cost

	# Clear selection before playing to avoid modification during iteration
	hand.clear_selection()

	# Play each card in sequence
	for card in cards_to_play:
		if current_state != CombatState.PLAYER_TURN:
			break
		if is_instance_valid(card):
			await _play_single_card(card.card_data, card)

	hand.update_playable_cards(player_energy)
	player_stats_changed.emit()

	_check_combat_end()

	if current_state == CombatState.PLAYER_TURN:
		await get_tree().process_frame
		_check_auto_end_turn()

func _play_single_card(card_data: CardData, card_instance: Card) -> void:
	"""Internal: Play a single card without deducting energy (used by play_selected_hand)."""
	cards_played_this_turn += 1

	# Track stats
	RunManager.record_card_played(card_data.card_type)

	# Calculate damage with bonuses
	var damage = card_data.get_effective_damage()
	if damage > 0:
		damage += RunManager.get_bonus_damage()
		if character.passive_type == CharacterData.PassiveType.BONUS_ATTACK_DAMAGE:
			damage += character.passive_value
		# Apply boss effect modifier
		damage = max(0, damage + get_boss_damage_modifier())

	# Calculate block with bonuses
	var block_amount = card_data.get_effective_block()
	if block_amount > 0:
		block_amount += RunManager.get_bonus_block()
		# Apply boss effect modifier
		block_amount = max(0, block_amount + get_boss_block_modifier())

	# Pre-set draw_on_kill before damage
	if card_data.special_effect == "draw_on_kill":
		pending_draw_on_kill = true

	# Apply effects
	match card_data.card_type:
		CardData.CardType.ATTACK:
			_deal_damage_to_enemy(damage)
		CardData.CardType.DEFEND:
			player_block += block_amount
			block_gained.emit("player", block_amount)
			player_stats_changed.emit()

	# Special effects
	_apply_card_special_effect(card_data)

	# Card goes to discard
	discard_pile.append(card_data)

	# Draw extra cards
	var draw_count = card_data.get_effective_draw()
	if draw_count > 0:
		_draw_cards(draw_count)

	# Animate and remove card (pass false to not emit card_played signal - energy already deducted)
	if card_instance:
		await card_instance.play_card_animation(false)
		hand.remove_card(card_instance)

func _apply_card_special_effect(card_data: CardData) -> void:
	"""Apply special effects from a card."""
	match card_data.special_effect:
		"weaken_2":
			enemy_weakened += 2
			card_effect_triggered.emit("WEAKENED!")
		"gain_energy_2":
			var energy_gain = 2 if not card_data.is_upgraded else 3
			player_energy += energy_gain
			card_effect_triggered.emit("+%d ENERGY!" % energy_gain)
		"fortify":
			var next_block = 5 if not card_data.is_upgraded else 8
			fortify_block += next_block
			card_effect_triggered.emit("FORTIFIED!")
		"self_damage_4":
			var self_dmg = 4
			player_hp -= self_dmg
			damage_dealt.emit("player", self_dmg)
			card_effect_triggered.emit("-%d HP" % self_dmg)
		"weaken_3_attack":
			enemy_weakened += 3
			var damage = card_data.get_effective_damage() + RunManager.get_bonus_damage()
			_deal_damage_to_enemy(damage)
			card_effect_triggered.emit("WEAKENED!")
		"multi_hit_3":
			var damage = card_data.get_effective_damage() + RunManager.get_bonus_damage()
			_deal_damage_to_enemy(damage)
			_deal_damage_to_enemy(damage)
			card_effect_triggered.emit("x3 HITS!")
		"gain_gold_8":
			var gold_gain = 8 if not card_data.is_upgraded else 12
			RunManager.run_gold += gold_gain
			gold_earned.emit(gold_gain)
			card_effect_triggered.emit("+%d GOLD!" % gold_gain)

func _deal_damage_to_enemy(damage: int) -> void:
	var final_damage = damage

	# Buster passive: crit chance
	if character.passive_type == CharacterData.PassiveType.CRIT_CHANCE:
		if randf() * 100.0 < character.passive_value:
			final_damage *= 2
			card_effect_triggered.emit("CRITICAL!")

	var actual_damage = max(0, final_damage - enemy_block)
	enemy_block = max(0, enemy_block - final_damage)
	enemy_hp -= actual_damage

	if actual_damage > 0:
		damage_dealt.emit("enemy", actual_damage)
		RunManager.record_damage(actual_damage, 0)

		# Evelone passive: gold on damage
		if character.passive_type == CharacterData.PassiveType.GOLD_ON_DAMAGE:
			var bonus_gold = character.passive_value
			RunManager.run_gold += bonus_gold
			gold_earned.emit(bonus_gold)

		# Mokrivskyi passive: lifesteal
		if character.passive_type == CharacterData.PassiveType.LIFESTEAL:
			var heal_amount = int(actual_damage * character.passive_value / 100.0)
			if heal_amount > 0:
				player_hp = min(player_hp + heal_amount, player_max_hp)
				card_effect_triggered.emit("+" + str(heal_amount) + " HP")
				player_stats_changed.emit()

	# Check if enemy was killed for Gaechka passive
	if enemy_hp <= 0 and character.passive_type == CharacterData.PassiveType.DRAW_ON_KILL:
		_draw_cards(character.passive_value)
		card_effect_triggered.emit("+" + str(character.passive_value) + " CARDS!")

	# Check for draw_on_kill special effect
	if enemy_hp <= 0 and pending_draw_on_kill:
		_draw_cards(1)
		card_effect_triggered.emit("+1 CARD!")

	# Always reset pending_draw_on_kill after damage is dealt
	pending_draw_on_kill = false

	enemy_stats_changed.emit()

func _deal_damage_to_player(damage: int) -> void:
	if enemy_weakened > 0:
		damage = max(0, damage - 2)

	var actual_damage = max(0, damage - player_block)
	player_block = max(0, player_block - damage)
	player_hp -= actual_damage

	if actual_damage > 0:
		damage_dealt.emit("player", actual_damage)
		RunManager.record_damage(0, actual_damage)
		RunManager.add_combat_damage_taken(actual_damage)

	player_stats_changed.emit()

func end_player_turn() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	for card in hand.cards.duplicate():
		discard_pile.append(card.card_data)
	hand.clear_hand()

	_start_enemy_turn()

func _start_enemy_turn() -> void:
	current_state = CombatState.ENEMY_TURN
	enemy_block = 0
	turn_changed.emit(false)
	enemy_stats_changed.emit()

	await get_tree().create_timer(0.6).timeout
	_execute_enemy_action()

func _decide_enemy_intent() -> void:
	# Smarter AI based on situation
	var attack_chance = 0.7

	# More defensive when player has low block
	if player_block > 10:
		attack_chance = 0.85

	# More aggressive when enemy is low HP
	if enemy_hp < enemy_max_hp * 0.3:
		attack_chance = 0.9

	if randf() < attack_chance:
		enemy_intent = "attack"
		var dmg_range = RunManager.get_enemy_damage_for_floor() if is_run_combat else Vector2i(6, 12)
		enemy_damage = randi_range(dmg_range.x, dmg_range.y)
	else:
		enemy_intent = "defend"

func _execute_enemy_action() -> void:
	match enemy_intent:
		"attack":
			_deal_damage_to_player(enemy_damage)
		"defend":
			var block_amount = int(8 * (RunManager.difficulty_multiplier if is_run_combat else 1.0))
			enemy_block += block_amount
			block_gained.emit("enemy", block_amount)

	if enemy_weakened > 0:
		enemy_weakened -= 1

	enemy_stats_changed.emit()
	_check_combat_end()

	if current_state != CombatState.COMBAT_OVER:
		await get_tree().create_timer(0.3).timeout
		_start_player_turn()

func _check_combat_end() -> void:
	if player_hp <= 0:
		current_state = CombatState.COMBAT_OVER
		combat_ended.emit(false)
	elif enemy_hp <= 0:
		current_state = CombatState.COMBAT_OVER
		gold_earned.emit(gold_reward)
		combat_ended.emit(true)

func get_draw_pile_count() -> int:
	return draw_pile.size()

func get_discard_pile_count() -> int:
	return discard_pile.size()
