extends CanvasLayer

# Visual Effects Manager - creates particles, glare, ambient effects, screen flash, transitions

# Particle colors
const GOLD_COLOR = Color(1, 0.85, 0.2)
const DAMAGE_COLOR = Color(1, 0.3, 0.3)
const HEAL_COLOR = Color(0.3, 1, 0.4)
const BLOCK_COLOR = Color(0.3, 0.6, 1)
const ENERGY_COLOR = Color(1, 0.9, 0.4)
const PURPLE_GLOW = Color(0.6, 0.4, 1)

# Screen overlays
var flash_overlay: ColorRect
var transition_overlay: ColorRect
var gradient_overlay: ColorRect
var ambient_container: Control
var gradient_shader: ShaderMaterial

# Ambient particles
const MAX_AMBIENT_PARTICLES = 25
var ambient_particles: Array[Control] = []

func _ready() -> void:
	layer = 100  # On top of everything
	_setup_gradient_overlay()
	_setup_ambient_particles()
	_setup_flash_overlay()
	_setup_transition_overlay()

func _setup_gradient_overlay() -> void:
	gradient_overlay = ColorRect.new()
	gradient_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	gradient_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float time_scale : hint_range(0.01, 1.0) = 0.12;
uniform float intensity : hint_range(0.0, 0.5) = 0.06;
uniform vec4 color1 : source_color = vec4(0.2, 0.1, 0.3, 1.0);
uniform vec4 color2 : source_color = vec4(0.1, 0.15, 0.25, 1.0);
uniform vec4 color3 : source_color = vec4(0.15, 0.1, 0.2, 1.0);

void fragment() {
	float t = TIME * time_scale;
	float wave1 = sin(UV.x * 2.0 + t) * 0.5 + 0.5;
	float wave2 = cos(UV.y * 2.0 + t * 0.7) * 0.5 + 0.5;
	float wave3 = sin((UV.x + UV.y) * 1.5 + t * 0.5) * 0.5 + 0.5;
	vec4 mixed = mix(color1, color2, wave1);
	mixed = mix(mixed, color3, wave2 * wave3);
	COLOR = vec4(mixed.rgb, intensity);
}
"""
	gradient_shader = ShaderMaterial.new()
	gradient_shader.shader = shader
	gradient_shader.set_shader_parameter("color1", Color(0.18, 0.08, 0.28, 1.0))
	gradient_shader.set_shader_parameter("color2", Color(0.08, 0.15, 0.25, 1.0))
	gradient_shader.set_shader_parameter("color3", Color(0.15, 0.06, 0.22, 1.0))
	gradient_overlay.material = gradient_shader
	add_child(gradient_overlay)

func _setup_ambient_particles() -> void:
	ambient_container = Control.new()
	ambient_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	ambient_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ambient_container)

	for i in range(MAX_AMBIENT_PARTICLES):
		_spawn_ambient_particle()

func _spawn_ambient_particle() -> void:
	var particle = ColorRect.new()
	particle.size = Vector2(randf_range(2, 5), randf_range(2, 5))
	particle.color = Color(1, 1, 1, randf_range(0.08, 0.2))
	particle.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var viewport_size = Vector2(800, 600)
	if get_viewport():
		viewport_size = get_viewport().get_visible_rect().size

	particle.position = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
	particle.set_meta("speed", randf_range(8, 25))
	particle.set_meta("drift", randf_range(-15, 15))
	particle.set_meta("alpha_base", particle.color.a)

	ambient_container.add_child(particle)
	ambient_particles.append(particle)

func _setup_flash_overlay() -> void:
	flash_overlay = ColorRect.new()
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_overlay.color = Color(1, 1, 1, 0)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash_overlay)

func _setup_transition_overlay() -> void:
	transition_overlay = ColorRect.new()
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color(0, 0, 0, 0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(transition_overlay)

func _process(delta: float) -> void:
	_update_ambient_particles(delta)

func _update_ambient_particles(delta: float) -> void:
	if not StatsManager.show_particles:
		ambient_container.visible = false
		return
	ambient_container.visible = true

	var viewport_size = Vector2(800, 600)
	if get_viewport():
		viewport_size = get_viewport().get_visible_rect().size

	for particle in ambient_particles:
		if not is_instance_valid(particle):
			continue

		var speed = particle.get_meta("speed")
		var drift = particle.get_meta("drift")

		particle.position.y -= speed * delta
		particle.position.x += drift * delta

		var alpha_base = particle.get_meta("alpha_base")
		particle.color.a = alpha_base + sin(Time.get_ticks_msec() * 0.002 + particle.position.x * 0.1) * 0.05

		if particle.position.y < -10:
			particle.position.y = viewport_size.y + 10
			particle.position.x = randf_range(0, viewport_size.x)

# ============ SCREEN FLASH EFFECTS ============

func flash_critical() -> void:
	_flash(Color(1, 0.85, 0.2, 0.5), 0.05, 0.2)
	vibrate_strong()

func flash_damage() -> void:
	_flash(Color(1, 0.15, 0.15, 0.35), 0.03, 0.12)
	vibrate_damage()

func flash_heal() -> void:
	_flash(Color(0.2, 1, 0.4, 0.25), 0.08, 0.25)

func flash_block() -> void:
	_flash(Color(0.3, 0.5, 1, 0.2), 0.03, 0.15)

func _flash(color: Color, fade_in: float, fade_out: float) -> void:
	if StatsManager.reduced_motion:
		return
	flash_overlay.color = Color(color.r, color.g, color.b, 0)
	var tween = create_tween()
	tween.tween_property(flash_overlay, "color:a", color.a, fade_in)
	tween.tween_property(flash_overlay, "color:a", 0.0, fade_out)

# ============ HAPTIC FEEDBACK ============

func vibrate_damage() -> void:
	if StatsManager.haptic_feedback:
		Input.vibrate_handheld(40)

func vibrate_strong() -> void:
	if StatsManager.haptic_feedback:
		Input.vibrate_handheld(100)

func vibrate_light() -> void:
	if StatsManager.haptic_feedback:
		Input.vibrate_handheld(20)

# ============ SCENE TRANSITIONS ============

func transition_to_scene(scene_path: String, duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 1.0, duration / 2)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	fade_in(duration / 2)

func fade_in(duration: float = 0.3) -> void:
	transition_overlay.color.a = 1.0
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, duration)

func fade_out(duration: float = 0.3) -> void:
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 1.0, duration)

# ============ GRADIENT CONTROL ============

func set_gradient_intensity(intensity: float) -> void:
	if gradient_shader:
		gradient_shader.set_shader_parameter("intensity", intensity)

# ============ ORIGINAL PARTICLE EFFECTS ============

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
