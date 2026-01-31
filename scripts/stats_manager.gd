extends Node

# Singleton for tracking all-time stats and records

# Lifetime stats
var total_runs: int = 0
var total_wins: int = 0
var total_losses: int = 0
var best_floor: int = 0
var total_enemies_defeated: int = 0
var total_damage_dealt: int = 0
var total_attack_cards_played: int = 0
var total_defend_cards_played: int = 0
var total_gold_earned: int = 0
var best_score: int = 0
var total_main_runs_completed: int = 0

# Recent runs (last 10)
var recent_runs: Array[Dictionary] = []

# Settings - Gameplay
var auto_end_turn: bool = true
var confirm_card_play: bool = false
var animation_speed: float = 1.0  # 0.5 to 2.0

# Settings - Visual
var screen_shake: bool = true
var show_damage_numbers: bool = true
var show_particles: bool = true
var show_glare: bool = true
var reduced_motion: bool = false

# Settings - Audio
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var haptic_feedback: bool = true

# Settings - Display
var ui_scale: float = 1.0  # 0.8 to 1.5
var card_size: float = 1.0  # 0.8 to 1.2
var high_contrast: bool = false
var show_card_borders: bool = true

# Settings - Language
var language: String = "en"  # en, uk, ru

# Settings - Debug
var debug_mode: bool = false

# Trial system
var chriswave_trials_remaining: int = 5  # Free combats before requiring unlock
const CHRISWAVE_MAX_TRIALS: int = 5

const SAVE_PATH = "user://stats.cfg"

func _ready() -> void:
	load_stats()

func record_run(victory: bool, floor_reached: int, enemies: int, damage: int,
				attacks: int, defends: int, score: int = 0) -> void:
	total_runs += 1
	if victory:
		total_wins += 1
		total_main_runs_completed += 1
	else:
		total_losses += 1

	if floor_reached > best_floor:
		best_floor = floor_reached

	if score > best_score:
		best_score = score

	total_enemies_defeated += enemies
	total_damage_dealt += damage
	total_attack_cards_played += attacks
	total_defend_cards_played += defends

	# Add to recent runs
	var run_data = {
		"victory": victory,
		"floor": floor_reached,
		"enemies": enemies,
		"damage": damage,
		"attacks": attacks,
		"defends": defends,
		"score": score,
		"timestamp": Time.get_unix_time_from_system()
	}

	recent_runs.push_front(run_data)
	if recent_runs.size() > 10:
		recent_runs.pop_back()

	save_stats()

func get_win_rate() -> float:
	if total_runs == 0:
		return 0.0
	return float(total_wins) / float(total_runs) * 100.0

func get_attack_defend_ratio() -> String:
	var total = total_attack_cards_played + total_defend_cards_played
	if total == 0:
		return "50% / 50%"

	var attack_pct = float(total_attack_cards_played) / float(total) * 100.0
	var defend_pct = float(total_defend_cards_played) / float(total) * 100.0
	return "%.0f%% / %.0f%%" % [attack_pct, defend_pct]

func get_favorite_playstyle() -> String:
	if total_attack_cards_played > total_defend_cards_played * 1.5:
		return "Aggressive"
	elif total_defend_cards_played > total_attack_cards_played * 1.5:
		return "Defensive"
	else:
		return "Balanced"

func save_stats() -> void:
	var config = ConfigFile.new()

	# Stats
	config.set_value("stats", "total_runs", total_runs)
	config.set_value("stats", "total_wins", total_wins)
	config.set_value("stats", "total_losses", total_losses)
	config.set_value("stats", "best_floor", best_floor)
	config.set_value("stats", "total_enemies", total_enemies_defeated)
	config.set_value("stats", "total_damage", total_damage_dealt)
	config.set_value("stats", "total_attacks", total_attack_cards_played)
	config.set_value("stats", "total_defends", total_defend_cards_played)
	config.set_value("stats", "total_gold", total_gold_earned)
	config.set_value("stats", "best_score", best_score)
	config.set_value("stats", "total_main_runs_completed", total_main_runs_completed)

	# Settings - Gameplay
	config.set_value("settings", "auto_end_turn", auto_end_turn)
	config.set_value("settings", "confirm_card_play", confirm_card_play)
	config.set_value("settings", "animation_speed", animation_speed)

	# Settings - Visual
	config.set_value("settings", "screen_shake", screen_shake)
	config.set_value("settings", "show_damage_numbers", show_damage_numbers)
	config.set_value("settings", "show_particles", show_particles)
	config.set_value("settings", "show_glare", show_glare)
	config.set_value("settings", "reduced_motion", reduced_motion)

	# Settings - Audio
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.set_value("settings", "haptic_feedback", haptic_feedback)

	# Settings - Display
	config.set_value("settings", "ui_scale", ui_scale)
	config.set_value("settings", "card_size", card_size)
	config.set_value("settings", "high_contrast", high_contrast)
	config.set_value("settings", "show_card_borders", show_card_borders)
	config.set_value("settings", "language", language)

	# Settings - Debug
	config.set_value("settings", "debug_mode", debug_mode)

	# Recent runs (simplified)
	config.set_value("history", "recent_runs", recent_runs)

	# Trial system
	config.set_value("trials", "chriswave_remaining", chriswave_trials_remaining)

	config.save(SAVE_PATH)

func load_stats() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	# Stats
	total_runs = config.get_value("stats", "total_runs", 0)
	total_wins = config.get_value("stats", "total_wins", 0)
	total_losses = config.get_value("stats", "total_losses", 0)
	best_floor = config.get_value("stats", "best_floor", 0)
	total_enemies_defeated = config.get_value("stats", "total_enemies", 0)
	total_damage_dealt = config.get_value("stats", "total_damage", 0)
	total_attack_cards_played = config.get_value("stats", "total_attacks", 0)
	total_defend_cards_played = config.get_value("stats", "total_defends", 0)
	total_gold_earned = config.get_value("stats", "total_gold", 0)
	best_score = config.get_value("stats", "best_score", 0)
	total_main_runs_completed = config.get_value("stats", "total_main_runs_completed", 0)

	# Settings - Gameplay
	auto_end_turn = config.get_value("settings", "auto_end_turn", true)
	confirm_card_play = config.get_value("settings", "confirm_card_play", false)
	animation_speed = config.get_value("settings", "animation_speed", 1.0)

	# Settings - Visual
	screen_shake = config.get_value("settings", "screen_shake", true)
	show_damage_numbers = config.get_value("settings", "show_damage_numbers", true)
	show_particles = config.get_value("settings", "show_particles", true)
	show_glare = config.get_value("settings", "show_glare", true)
	reduced_motion = config.get_value("settings", "reduced_motion", false)

	# Settings - Audio
	music_volume = config.get_value("settings", "music_volume", 0.8)
	sfx_volume = config.get_value("settings", "sfx_volume", 1.0)
	haptic_feedback = config.get_value("settings", "haptic_feedback", true)

	# Settings - Display
	ui_scale = config.get_value("settings", "ui_scale", 1.0)
	card_size = config.get_value("settings", "card_size", 1.0)
	high_contrast = config.get_value("settings", "high_contrast", false)
	show_card_borders = config.get_value("settings", "show_card_borders", true)
	language = config.get_value("settings", "language", "en")

	# Settings - Debug
	debug_mode = config.get_value("settings", "debug_mode", false)

	# Apply language (Localization autoload handles this after it loads)

	# Recent runs
	recent_runs = config.get_value("history", "recent_runs", [])

	# Trial system
	chriswave_trials_remaining = config.get_value("trials", "chriswave_remaining", CHRISWAVE_MAX_TRIALS)

func reset_stats() -> void:
	total_runs = 0
	total_wins = 0
	total_losses = 0
	best_floor = 0
	total_enemies_defeated = 0
	total_damage_dealt = 0
	total_attack_cards_played = 0
	total_defend_cards_played = 0
	total_gold_earned = 0
	best_score = 0
	total_main_runs_completed = 0
	recent_runs.clear()
	chriswave_trials_remaining = CHRISWAVE_MAX_TRIALS
	save_stats()

# Trial system functions
func has_chriswave_trials() -> bool:
	return chriswave_trials_remaining > 0

func get_chriswave_trials() -> int:
	return chriswave_trials_remaining

func use_chriswave_trial() -> void:
	if chriswave_trials_remaining > 0:
		chriswave_trials_remaining -= 1
		save_stats()
