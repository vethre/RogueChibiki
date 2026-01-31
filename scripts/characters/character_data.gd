extends Resource
class_name CharacterData

enum PassiveType {
	START_WITH_BLOCK,      # Tank: Start combat with +X block
	BONUS_ATTACK_DAMAGE,   # Aggro: Deal +X damage with attacks
	ENEMY_WEAKEN,          # Control: Enemies start with -X strength
	COMBO_FREE_CARD,       # Combo: Every Xth card costs 0
	GOLD_ON_DAMAGE,        # Evelone: Earn +X gold when dealing damage
	CRIT_CHANCE,           # Buster: X% chance to deal double damage
	LIFESTEAL,             # Mokrivskyi: Heal for X% of damage dealt
	BONUS_ENERGY,          # Chriswave: Start each turn with +X energy
	DRAW_ON_KILL           # Gaechka: Draw +X cards when enemy dies
}

@export var character_name: String = "Chibiki"
@export var portrait: Texture2D
@export var passive_type: PassiveType = PassiveType.START_WITH_BLOCK
@export var passive_value: int = 5
@export_multiline var passive_description: String = ""
@export var starting_hp: int = 50
@export var starting_energy: int = 3

# Starting deck composition
@export var strike_count: int = 5
@export var defend_count: int = 3
@export var special_cards: Array[Resource] = []  # Character-specific cards

@export var is_unlocked: bool = true
@export var unlock_cost: int = 0
