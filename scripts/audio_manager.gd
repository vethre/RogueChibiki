extends Node

# Audio buses
var music_player: AudioStreamPlayer
var music_player_fade: AudioStreamPlayer  # Second player for crossfade
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

# Crossfade settings
const CROSSFADE_DURATION: float = 1.5
var _crossfade_tween: Tween = null
var _current_music_player: AudioStreamPlayer
var _fade_music_player: AudioStreamPlayer

# Music tracks
var music_combat: AudioStream
var music_shop: AudioStream
var music_boss: AudioStream

# Current music type for tracking
enum MusicType { NONE, COMBAT, SHOP, BOSS }
var current_music_type: MusicType = MusicType.NONE

# Preloaded SFX
var sfx_pickup_card: AudioStream
var sfx_punch: AudioStream
var sfx_purchase: AudioStream
var sfx_block: AudioStream
var sfx_packs_open: AudioStream

func _ready() -> void:
	_setup_audio_players()
	_load_audio_files()

	# Apply saved volume settings
	set_music_volume(StatsManager.music_volume)
	set_sfx_volume(StatsManager.sfx_volume)

	# Start with combat music (main menu / default)
	play_combat_music()

func _setup_audio_players() -> void:
	# Create two music players for crossfade
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

	music_player_fade = AudioStreamPlayer.new()
	music_player_fade.bus = "Master"
	add_child(music_player_fade)

	_current_music_player = music_player
	_fade_music_player = music_player_fade

	# Create pool of SFX players
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func _load_audio_files() -> void:
	# Load music tracks
	music_combat = load("res://assets/music/background-jazz.mp3")
	music_shop = load("res://assets/music/shop-jazz.mp3")
	music_boss = load("res://assets/music/boss-music.mp3")

	# Load SFX
	sfx_pickup_card = load("res://assets/sfx/pickup-card.mp3")
	sfx_punch = load("res://assets/sfx/punch.mp3")
	sfx_purchase = load("res://assets/sfx/purchase.mp3")
	sfx_block = load("res://assets/sfx/block.mp3")
	sfx_packs_open = load("res://assets/sfx/packs-open.mp3")

# Music control with smooth crossfade
func _crossfade_to(new_stream: AudioStream, new_type: MusicType) -> void:
	if new_stream == null:
		return

	# Don't restart same music
	if current_music_type == new_type and _current_music_player.playing:
		return

	current_music_type = new_type

	# Kill any existing tween
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()

	# Swap the players
	var old_player = _current_music_player
	var new_player = _fade_music_player
	_current_music_player = new_player
	_fade_music_player = old_player

	# Setup new player
	new_player.stream = new_stream
	var target_volume = linear_to_db(StatsManager.music_volume) if StatsManager.music_volume > 0 else -80
	new_player.volume_db = -80  # Start silent
	new_player.play()

	# Disconnect old finished signal if connected
	if old_player.finished.is_connected(_on_music_finished):
		old_player.finished.disconnect(_on_music_finished)

	# Connect new player loop
	if not new_player.finished.is_connected(_on_music_finished):
		new_player.finished.connect(_on_music_finished)

	# Create crossfade tween
	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)

	# Fade out old
	if old_player.playing:
		_crossfade_tween.tween_property(old_player, "volume_db", -80, CROSSFADE_DURATION)

	# Fade in new
	_crossfade_tween.tween_property(new_player, "volume_db", target_volume, CROSSFADE_DURATION)

	# Stop old player after fade
	_crossfade_tween.chain().tween_callback(func(): old_player.stop())

func play_combat_music() -> void:
	_crossfade_to(music_combat, MusicType.COMBAT)

func play_shop_music() -> void:
	_crossfade_to(music_shop, MusicType.SHOP)

func play_boss_music() -> void:
	_crossfade_to(music_boss, MusicType.BOSS)

# Legacy method for compatibility
func play_music() -> void:
	play_combat_music()

func _on_music_finished() -> void:
	if _current_music_player.stream:
		_current_music_player.play()

func stop_music() -> void:
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
	music_player.stop()
	music_player_fade.stop()
	current_music_type = MusicType.NONE

func set_music_volume(volume: float) -> void:
	var db = -80 if volume <= 0 else linear_to_db(volume)
	# Apply to current playing music player
	if _current_music_player and _current_music_player.playing:
		_current_music_player.volume_db = db

func set_sfx_volume(volume: float) -> void:
	var db = -80 if volume <= 0 else linear_to_db(volume)
	for player in sfx_players:
		player.volume_db = db

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# If all are busy, return the first one (will interrupt)
	return sfx_players[0]

func play_sfx(sound: AudioStream) -> void:
	if sound == null:
		return
	var player = _get_available_sfx_player()
	player.stream = sound
	player.volume_db = linear_to_db(StatsManager.sfx_volume) if StatsManager.sfx_volume > 0 else -80
	player.play()

# Convenience methods for specific sounds
func play_card_pickup() -> void:
	play_sfx(sfx_pickup_card)

func play_punch() -> void:
	play_sfx(sfx_punch)

func play_purchase() -> void:
	play_sfx(sfx_purchase)

func play_block() -> void:
	play_sfx(sfx_block)

func play_packs_open() -> void:
	play_sfx(sfx_packs_open)
