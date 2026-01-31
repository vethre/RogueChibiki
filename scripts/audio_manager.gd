extends Node

# Audio buses
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

# Preloaded sounds
var sfx_pickup_card: AudioStream
var sfx_punch: AudioStream
var sfx_purchase: AudioStream
var music_background: AudioStream

func _ready() -> void:
	_setup_audio_players()
	_load_audio_files()

	# Apply saved volume settings
	set_music_volume(StatsManager.music_volume)
	set_sfx_volume(StatsManager.sfx_volume)

	# Start background music
	play_music()

func _setup_audio_players() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

	# Create pool of SFX players
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

func _load_audio_files() -> void:
	# Load music
	music_background = load("res://assets/music/background-jazz.mp3")

	# Load SFX
	sfx_pickup_card = load("res://assets/sfx/pickup-card.mp3")
	sfx_punch = load("res://assets/sfx/punch.mp3")
	sfx_purchase = load("res://assets/sfx/purchase.mp3")

func play_music() -> void:
	if music_background and not music_player.playing:
		music_player.stream = music_background
		music_player.play()
		# Loop the music
		music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if music_player.stream:
		music_player.play()

func stop_music() -> void:
	music_player.stop()

func set_music_volume(volume: float) -> void:
	# volume is 0.0 to 1.0
	if volume <= 0:
		music_player.volume_db = -80
	else:
		music_player.volume_db = linear_to_db(volume)

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
