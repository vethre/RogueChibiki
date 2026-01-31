extends Resource
class_name EventData

enum EventType { TRADE, GAMBLE, REWARD, CURSE }

@export var event_name: String = "Event"
@export_multiline var description: String = ""
@export var event_type: EventType = EventType.TRADE
@export var choices: Array[Dictionary] = []
# Each choice: {"text": "Button text", "effect_type": "heal/damage/gold/card/relic", "effect_value": 10}

static func create_random_event() -> Dictionary:
	var events = [
		{
			"name": "Mysterious Stranger",
			"description": "A hooded figure approaches you in the shadows. They offer a trade...",
			"type": EventType.TRADE,
			"choices": [
				{"text": "Trade 10 HP for 50 Gold", "effects": [{"type": "damage", "value": 10}, {"type": "gold", "value": 50}]},
				{"text": "Trade 30 Gold for 15 HP", "effects": [{"type": "gold", "value": -30}, {"type": "heal", "value": 15}]},
				{"text": "Leave", "effects": []}
			]
		},
		{
			"name": "Abandoned Chest",
			"description": "You find an old chest. It could contain treasure... or a trap.",
			"type": EventType.GAMBLE,
			"choices": [
				{"text": "Open it (70% reward, 30% trap)", "effects": [{"type": "gamble", "success_value": 40, "fail_value": -15}]},
				{"text": "Leave it alone", "effects": []}
			]
		},
		{
			"name": "Training Dummy",
			"description": "A magical training dummy stands before you. It can enhance your skills.",
			"type": EventType.REWARD,
			"choices": [
				{"text": "Upgrade a random card (Free)", "effects": [{"type": "upgrade_random", "value": 1}]},
				{"text": "Keep moving", "effects": []}
			]
		},
		{
			"name": "Shady Merchant",
			"description": "A merchant offers items at suspiciously low prices...",
			"type": EventType.TRADE,
			"choices": [
				{"text": "Buy a Relic for 25 Gold", "effects": [{"type": "gold", "value": -25}, {"type": "relic", "value": 1}]},
				{"text": "Too risky, leave", "effects": []}
			]
		},
		{
			"name": "Ancient Shrine",
			"description": "An ancient shrine glows with mysterious energy.",
			"type": EventType.TRADE,
			"choices": [
				{"text": "Pray (Heal 20 HP)", "effects": [{"type": "heal", "value": 20}]},
				{"text": "Offer Gold (50 Gold for +5 Max HP)", "effects": [{"type": "gold", "value": -50}, {"type": "max_hp", "value": 5}]},
				{"text": "Walk away", "effects": []}
			]
		},
		{
			"name": "Wandering Soul",
			"description": "A lost spirit asks for help. Will you aid it?",
			"type": EventType.REWARD,
			"choices": [
				{"text": "Help the spirit (Get 1 Bouquet)", "effects": [{"type": "bouquet", "value": 1}]},
				{"text": "Ignore it", "effects": []}
			]
		}
	]
	return events[randi() % events.size()]
