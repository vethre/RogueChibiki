extends Resource
class_name ConsumableData

enum ConsumableEffect {
	HEAL,           # Heal X HP
	ENERGY,         # Gain X energy this turn
	DAMAGE,         # Deal X damage to enemy
	BLOCK,          # Gain X block
	DRAW,           # Draw X cards
	GOLD,           # Gain X gold
	WEAKEN,         # Weaken enemy for X turns
	UPGRADE_RANDOM, # Upgrade a random card
	REMOVE_CARD,    # Remove a card from deck
	MAX_HP,         # Increase max HP by X
}

@export var consumable_name: String = "Consumable"
@export_multiline var description: String = ""
@export var effect_type: ConsumableEffect = ConsumableEffect.HEAL
@export var effect_value: int = 10
@export var icon: Texture2D

func get_effect_description() -> String:
	match effect_type:
		ConsumableEffect.HEAL:
			return "Heal %d HP" % effect_value
		ConsumableEffect.ENERGY:
			return "+%d Energy" % effect_value
		ConsumableEffect.DAMAGE:
			return "Deal %d damage" % effect_value
		ConsumableEffect.BLOCK:
			return "Gain %d Block" % effect_value
		ConsumableEffect.DRAW:
			return "Draw %d cards" % effect_value
		ConsumableEffect.GOLD:
			return "Gain %d Gold" % effect_value
		ConsumableEffect.WEAKEN:
			return "Weaken enemy %d turns" % effect_value
		ConsumableEffect.UPGRADE_RANDOM:
			return "Upgrade random card"
		ConsumableEffect.REMOVE_CARD:
			return "Remove a card"
		ConsumableEffect.MAX_HP:
			return "+%d Max HP" % effect_value
	return description
