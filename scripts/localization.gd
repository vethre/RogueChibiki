extends Node

# Localization system that uses Godot's built-in TranslationServer
# This ensures translations work on mobile without export filter issues

signal locale_changed(new_locale: String)

var current_locale: String = "en"

func _ready() -> void:
	# Apply saved language after a frame (StatsManager loads first)
	await get_tree().process_frame
	if StatsManager:
		set_locale(StatsManager.language)

func set_locale(locale: String) -> void:
	print("Localization: Setting locale to: ", locale)
	current_locale = locale
	TranslationServer.set_locale(locale)
	locale_changed.emit(locale)

func get_locale() -> String:
	return current_locale

func get_text(key: String, args = null) -> String:
	# Use Godot's built-in translation system
	var text = tr(key)

	# If translation not found, tr() returns the key itself
	if text == key:
		return key

	# Handle format arguments (e.g., %d, %s)
	if args != null and args is Array and args.size() > 0:
		text = _replace_format_args(text, args)

	return text

func _replace_format_args(text: String, args: Array) -> String:
	# Replace %d and %s placeholders with provided arguments
	var result = text
	for i in range(args.size()):
		var arg = args[i]
		var value = arg if arg != null else 0
		var str_value = str(value)
		# Find and replace first occurrence of %d or %s
		var pos_d = result.find("%d")
		var pos_s = result.find("%s")
		if pos_d != -1 and (pos_s == -1 or pos_d < pos_s):
			result = result.substr(0, pos_d) + str_value + result.substr(pos_d + 2)
		elif pos_s != -1:
			result = result.substr(0, pos_s) + str_value + result.substr(pos_s + 2)
	return result

# Shorthand alias
func t(key: String, args = null) -> String:
	return get_text(key, args)

# Helper for character names - converts "Chibiki" to key "CHAR_CHIBIKI_NAME"
func char_name(character_name: String) -> String:
	var key = "CHAR_" + character_name.to_upper().replace(" ", "_") + "_NAME"
	var result = get_text(key)
	# Fallback to original name if no translation
	return character_name if result == key else result

# Helper for character passive descriptions
func char_passive(character_name: String) -> String:
	var key = "CHAR_" + character_name.to_upper().replace(" ", "_") + "_PASSIVE"
	var result = get_text(key)
	return result if result != key else ""

# Helper for card names - converts "Strike" to key "CARD_STRIKE_NAME"
func card_name(card_name_str: String) -> String:
	var key = "CARD_" + card_name_str.to_upper().replace(" ", "_") + "_NAME"
	var result = get_text(key)
	return card_name_str if result == key else result

# Helper for card descriptions
func card_desc(card_name_str: String) -> String:
	var key = "CARD_" + card_name_str.to_upper().replace(" ", "_") + "_DESC"
	var result = get_text(key)
	return result if result != key else ""

# Helper for skin names - converts "chibiki_spring" to key "SKIN_CHIBIKI_SPRING_NAME"
func skin_name(skin_id: String) -> String:
	var key = "SKIN_" + skin_id.to_upper() + "_NAME"
	var result = get_text(key)
	# Fallback: prettify the id
	if result == key:
		return skin_id.replace("_", " ").capitalize()
	return result
