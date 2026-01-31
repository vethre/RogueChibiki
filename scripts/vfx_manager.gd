extends Node

# Visual Effects Manager - creates particles, glare, and ambient effects

# Particle colors
const GOLD_COLOR = Color(1, 0.85, 0.2)
const DAMAGE_COLOR = Color(1, 0.3, 0.3)
const HEAL_COLOR = Color(0.3, 1, 0.4)
const BLOCK_COLOR = Color(0.3, 0.6, 1)
const ENERGY_COLOR = Color(1, 0.9, 0.4)
const PURPLE_GLOW = Color(0.6, 0.4, 1)

# Create floating particles at position
func spawn_particles(parent: Node, pos: Vector2, color: Color, count: int = 8) -> void:
	if not StatsManager.show_particles:
		return

	for i in range(count):
		var particle = _create_particle(color)
		parent.add_child(particle)
		particle.global_position = pos

		var angle = randf() * TAU
		var distance = randf_range(30, 80)
		var target = pos + Vector2(cos(angle), sin(angle)) * distance

		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", target, randf_range(0.4, 0.8))
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.5, 0.9))
		tween.tween_property(particle, "scale", Vector2(0.2, 0.2), randf_range(0.5, 0.9))
		tween.chain().tween_callback(particle.queue_free)

func _create_particle(color: Color) -> Control:
	var particle = Panel.new()
	particle.custom_minimum_size = Vector2(8, 8)
	particle.size = Vector2(8, 8)
	particle.pivot_offset = Vector2(4, 4)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	particle.add_theme_stylebox_override("panel", style)

	return particle

# Create glowing orb effect - uses layered circles for soft glow appearance
func spawn_glow(parent: Node, pos: Vector2, color: Color, size: float = 100) -> void:
	if not StatsManager.show_glare:
		return

	# Create container for the glow layers
	var glow_container = Control.new()
	glow_container.position = pos - Vector2(size/2, size/2)
	glow_container.custom_minimum_size = Vector2(size, size)
	glow_container.size = Vector2(size, size)
	glow_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(glow_container)
	parent.move_child(glow_container, 0)

	# Create multiple layered circles for soft glow effect
	var layers = [
		{"scale": 1.0, "alpha": 0.15},
		{"scale": 0.7, "alpha": 0.25},
		{"scale": 0.4, "alpha": 0.4},
	]

	for layer in layers:
		var circle = Panel.new()
		var layer_size = size * layer.scale
		circle.custom_minimum_size = Vector2(layer_size, layer_size)
		circle.size = Vector2(layer_size, layer_size)
		circle.position = Vector2((size - layer_size) / 2, (size - layer_size) / 2)
		circle.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var style = StyleBoxFlat.new()
		style.bg_color = Color(color.r, color.g, color.b, layer.alpha)
		# Make it circular by setting corner radius to half the size
		var radius = int(layer_size / 2)
		style.corner_radius_top_left = radius
		style.corner_radius_top_right = radius
		style.corner_radius_bottom_left = radius
		style.corner_radius_bottom_right = radius
		circle.add_theme_stylebox_override("panel", style)
		glow_container.add_child(circle)

	# Animate fade out with slight scale up for glow expansion effect
	glow_container.pivot_offset = Vector2(size/2, size/2)
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(glow_container, "modulate:a", 0.0, 0.6)
	tween.tween_property(glow_container, "scale", Vector2(1.3, 1.3), 0.6)
	tween.chain().tween_callback(glow_container.queue_free)

# Create rising text effect
func spawn_floating_text(parent: Node, pos: Vector2, text: String, color: Color, font_size: int = 24) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = pos
	label.pivot_offset = Vector2(50, 15)
	label.scale = Vector2(0.5, 0.5)
	parent.add_child(label)

	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", pos.y - 60, 0.8)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)
	tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)

# Gold pickup effect
func gold_effect(parent: Node, pos: Vector2, amount: int) -> void:
	spawn_particles(parent, pos, GOLD_COLOR, 12)
	spawn_floating_text(parent, pos, "+%d" % amount, GOLD_COLOR, 28)
	spawn_glow(parent, pos, GOLD_COLOR, 80)

# Damage effect
func damage_effect(parent: Node, pos: Vector2, amount: int) -> void:
	spawn_particles(parent, pos, DAMAGE_COLOR, 10)
	spawn_floating_text(parent, pos, "-%d" % amount, DAMAGE_COLOR, 32)

# Heal effect
func heal_effect(parent: Node, pos: Vector2, amount: int) -> void:
	spawn_particles(parent, pos, HEAL_COLOR, 8)
	spawn_floating_text(parent, pos, "+%d" % amount, HEAL_COLOR, 28)

# Block effect
func block_effect(parent: Node, pos: Vector2, amount: int) -> void:
	spawn_particles(parent, pos, BLOCK_COLOR, 6)
	spawn_floating_text(parent, pos, "+%d" % amount, BLOCK_COLOR, 24)

# Card play burst
func card_burst(parent: Node, pos: Vector2, card_color: Color) -> void:
	spawn_particles(parent, pos, card_color, 15)
	spawn_glow(parent, pos, card_color, 120)

# Victory celebration
func victory_burst(parent: Node) -> void:
	if not parent:
		return

	var center = parent.size / 2 if parent is Control else Vector2(400, 300)

	for i in range(5):
		await parent.get_tree().create_timer(0.1).timeout
		var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		spawn_particles(parent, center + offset, GOLD_COLOR, 20)
		spawn_particles(parent, center + offset, PURPLE_GLOW, 15)

# Lightning effect for energy upgrades
func lightning_effect(parent: Node, pos: Vector2) -> void:
	if not StatsManager.show_particles:
		return

	# Create multiple lightning bolts
	for i in range(3):
		_spawn_lightning_bolt(parent, pos, i * 0.1)

	# Add electric particles
	spawn_particles(parent, pos, ENERGY_COLOR, 20)

	# Add bright flash
	spawn_glow(parent, pos, Color(1, 1, 0.8), 150)

	# Add floating text
	spawn_floating_text(parent, pos, "⚡ +1 ENERGY ⚡", ENERGY_COLOR, 22)

func _spawn_lightning_bolt(parent: Node, start_pos: Vector2, delay: float) -> void:
	await parent.get_tree().create_timer(delay).timeout

	# Create a jagged lightning path using Line2D
	var lightning = Line2D.new()
	lightning.width = 4
	lightning.default_color = Color(1, 1, 0.6, 0.9)
	lightning.begin_cap_mode = Line2D.LINE_CAP_ROUND
	lightning.end_cap_mode = Line2D.LINE_CAP_ROUND

	# Generate jagged path
	var points: PackedVector2Array = []
	var current_pos = start_pos + Vector2(randf_range(-30, 30), -80)
	points.append(current_pos)

	var segments = randi_range(4, 7)
	for j in range(segments):
		current_pos.x += randf_range(-25, 25)
		current_pos.y += randf_range(15, 30)
		points.append(current_pos)

	lightning.points = points
	parent.add_child(lightning)

	# Add glow effect to lightning
	var glow_lightning = Line2D.new()
	glow_lightning.width = 12
	glow_lightning.default_color = Color(1, 1, 0.5, 0.3)
	glow_lightning.points = points
	glow_lightning.begin_cap_mode = Line2D.LINE_CAP_ROUND
	glow_lightning.end_cap_mode = Line2D.LINE_CAP_ROUND
	parent.add_child(glow_lightning)
	parent.move_child(glow_lightning, lightning.get_index())

	# Animate fade out
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(lightning, "modulate:a", 0.0, 0.3)
	tween.tween_property(glow_lightning, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(lightning.queue_free)
	tween.tween_callback(glow_lightning.queue_free)
