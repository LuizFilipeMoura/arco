class_name SoundPulse
extends Area2D

# === CONFIGURAÇÕES ===
@export var pulse_variation: float = 5.0
@export var pulse_speed: float = 5.0

# === ESTADOS ===
var target_radius: float = 100.0
var current_radius: float = 0.0
var pulse_timer: float = 0.0
var is_active: bool = true
var expand_speed: float = 600.0
var shrink_speed: float = 400.0

# === CONSTANTES ===
const BASE_RADIUS: float = 64.0  # depende do seu sprite

# === FUNÇÕES DE CICLO ===
func _ready():
	collision_layer = 1 << 1   # Layer 2 (SoundPulse)
	collision_mask = 0         # Não precisa detectar nada
	add_to_group("SoundPulse")
	set_process(true)

func _process(delta):
	if is_active:
		update_expand_or_pulse(delta)
	else:
		update_shrink(delta)

	update_visual_scale()

# === CONTROLE DE ESTADO ===
func set_radius(target: float):
	target_radius = target
	is_active = true

func deactivate():
	is_active = false

# === ATUALIZAÇÕES DE COMPORTAMENTO ===
func update_expand_or_pulse(delta: float):
	if current_radius < target_radius:
		current_radius = min(current_radius + expand_speed * delta, target_radius)
	else:
		pulse_timer += delta * pulse_speed
		var variation = sin(pulse_timer) * pulse_variation
		current_radius = target_radius + variation

func update_shrink(delta: float):
	current_radius -= shrink_speed * delta
	if current_radius <= 0.0:
		queue_free()

# === VISUAL ===
func update_visual_scale():
	var scale_factor = current_radius / BASE_RADIUS
	scale = Vector2(scale_factor, scale_factor)

# === FUNÇÃO GLOBAL DE FÁBRICA ===
static func spawn(
	parent: Node,
	radius: float,
	pos: Vector2 = Vector2.ZERO,
	auto_deactivate_delay: float = -1.0,
	grow_time: float = 0.2,
	shrink_time: float = 0.3
) -> SoundPulse:
	var pulse_scene = preload("res://char/sound_pulse.tscn")
	var pulse = pulse_scene.instantiate() as SoundPulse
	parent.add_child(pulse)
	pulse.global_position = parent.to_global(pos)
	pulse.set_radius(radius)

	# Calcula speeds a partir do tempo desejado
	pulse.expand_speed = radius / max(grow_time, 0.001)
	pulse.shrink_speed = radius / max(shrink_time, 0.001)

	# Se for auto-deactivate, dispara o timer
	if auto_deactivate_delay > 0.0:
		pulse._auto_deactivate(auto_deactivate_delay)

	return pulse

# === FUNÇÃO PRIVADA DE AUTO-DEACTIVATE ===
func _auto_deactivate(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	deactivate()
