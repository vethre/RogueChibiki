extends Resource
class_name RelicData

enum RelicRarity { COMMON, UNCOMMON, RARE, LEGENDARY }
enum RelicEffect {
	BONUS_DAMAGE,      # +X damage per attack
	BONUS_BLOCK,       # +X block per defend
	START_COMBAT_BLOCK,# Gain X block at combat start
	BONUS_GOLD,        # +X% gold from all sources
	HEAL_ON_KILL,      # Heal X HP on enemy kill
	BONUS_ENERGY,      # +X energy on first turn
	BONUS_DRAW,        # +X cards drawn per turn
	CRIT_CHANCE,       # X% chance for double damage
	LIFESTEAL,         # Heal X% of damage dealt
	MAX_HP_BONUS       # +X max HP
}

@export var relic_name: String = "Relic"
@export_multiline var description: String = ""
@export var effect_type: RelicEffect = RelicEffect.BONUS_DAMAGE
@export var effect_value: int = 1
@export var rarity: RelicRarity = RelicRarity.COMMON
@export var icon: Texture2D
@export var break_chance: float = 0.0  # Chance to break after combat (0-100%)
@export var is_fragile: bool = false  # If true, can break

# Runtime state (not persisted in resource)
var uses_remaining: int = -1  # -1 = infinite uses

func get_rarity_color() -> Color:
	match rarity:
		RelicRarity.COMMON:
			return Color(0.7, 0.7, 0.7, 1)
		RelicRarity.UNCOMMON:
			return Color(0.3, 0.8, 0.4, 1)
		RelicRarity.RARE:
			return Color(0.4, 0.6, 1, 1)
		RelicRarity.LEGENDARY:
			return Color(1, 0.8, 0.2, 1)
	return Color.WHITE
