extends Resource
class_name CardData

enum CardType { ATTACK, DEFEND, SKILL, POWER }
enum CardRarity { COMMON, UNCOMMON, RARE }

@export var card_name: String = "Card"
@export var energy_cost: int = 1
@export var card_type: CardType = CardType.ATTACK
@export_multiline var description: String = ""
@export var rarity: CardRarity = CardRarity.COMMON

# Effect values
@export var damage: int = 0
@export var block: int = 0
@export var draw_cards: int = 0
@export var special_effect: String = ""

# Upgrade values (added to base when upgraded) - Increased for more impactful upgrades
@export var upgrade_damage: int = 5
@export var upgrade_block: int = 5
@export var upgrade_draw: int = 1
@export var upgrade_cost_increase: int = 0  # No extra cost - upgrades are now pure buffs

# Visual
@export var icon: Texture2D

# Runtime state (not saved in .tres, set per instance)
var is_upgraded: bool = false
var chaos_cost: int = -1  # Used by SHUFFLED_HAND boss effect (-1 = not active)

func get_effective_damage() -> int:
	if is_upgraded:
		return damage + upgrade_damage
	return damage

func get_effective_block() -> int:
	if is_upgraded:
		return block + upgrade_block
	return block

func get_effective_draw() -> int:
	if is_upgraded:
		return draw_cards + upgrade_draw
	return draw_cards

func get_effective_cost() -> int:
	# Chaos cost overrides normal cost (boss effect)
	if chaos_cost >= 0:
		return chaos_cost
	if is_upgraded:
		return energy_cost + upgrade_cost_increase
	return energy_cost

func get_display_name() -> String:
	if is_upgraded:
		return card_name + "+"
	return card_name

func get_upgraded_description() -> String:
	var desc = description
	if is_upgraded:
		if damage > 0:
			desc = desc.replace(str(damage), str(get_effective_damage()))
		if block > 0:
			desc = desc.replace(str(block), str(get_effective_block()))
		if draw_cards > 0:
			desc = desc.replace("Draw " + str(draw_cards), "Draw " + str(get_effective_draw()))
	return desc

func upgrade() -> void:
	is_upgraded = true
