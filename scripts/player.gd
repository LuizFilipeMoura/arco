class_name Player
extends CharacterBody2D

# === CONFIGURAÇÕES DO PLAYER ===
@export var speed: float = 500.0
@export var max_health: int = 5

# === CONFIGURAÇÕES DO ARCO ===
@export var arrow_scene: PackedScene
@export var max_charge_time: float = 1
@export var max_force_multiplier: float = 5  # máximo multiplicador de dano
@export var base_arrow_speed: float = 400.0

# === CONFIGURAÇÕES DO PASSO / SOM ===
@export var sound_pulse_scene: PackedScene
@export var step_sound_min_radius: float = 50.0
@export var step_sound_max_radius: float = 100.0
@export var step_sound_interval: float = 0.3
@export var stop_velocity_threshold: float = 100.0

# === REFERÊNCIAS DE NÓS ===
@onready var bow_sprite: Sprite2D = $BowSprite
@onready var bow_force_label: Label = $BowForceLabel

# === HEALTH MANAGEMENT ===
@onready var health_manager = $HealthManagement

# === NAVEGAÇÃO ===
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var has_order: bool = false

# === ESTADOS ===
var has_bow: bool = false
var is_charging: bool = false
var charge_start_time: float = 0.0
var step_sound_pulse: Area2D = null

# === CICLO DE FÍSICA ===
@export var stop_move_distance: float = 20.0
@export var stop_threshold_distance: float = 4.0


func _ready() -> void:
	nav_agent.radius = 32.0
	nav_agent.neighbor_distance = 64.0
	nav_agent.avoidance_enabled = true
	nav_agent.avoidance_layers = 1
	nav_agent.avoidance_priority = 1.0

	health_manager.max_health = max_health
	health_manager.hurtbox = $HurtBox.get_path()
	health_manager.connect("damaged", Callable(self, "_on_health_changed"))
	health_manager.connect("healed", Callable(self, "_on_health_changed"))
	health_manager.connect("died", Callable(self, "_on_player_died"))

func _process_order(delta: float) -> void:
	var next_pos = nav_agent.get_next_path_position()
	var to_next = next_pos - global_position
	var dist = to_next.length()
	if dist <= stop_threshold_distance:
		global_position = next_pos
		_stop_order()
		return
	var dir = to_next / dist
	velocity = dir * speed
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	if collision:
		_stop_order()

func _stop_order() -> void:
	has_order = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position

func _process(delta: float) -> void:
	update_step_sound()
	update_bow_ui()

func _physics_process(delta: float) -> void:
	if has_order:
		_process_order(delta)

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if PlayerController.current_player == self:
			has_order = true
			nav_agent.target_position = get_global_mouse_position()
	if has_bow:
		handle_bow_input(event)

func is_moving() -> bool:
	return velocity.length() > 0.1

func handle_bow_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_charging()
		else:
			release_arrow()

func start_charging() -> void:
	is_charging = true
	charge_start_time = Time.get_ticks_msec() / 1000.0

func release_arrow() -> void:
	is_charging = false
	var charge_duration = get_current_charge_duration()
	shoot_arrow(charge_duration)

func shoot_arrow(charge_duration: float) -> void:
	# instancia e adiciona a flecha
	var arrow = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	print("arrow", arrow)
	arrow.global_position = global_position

	# direção e carregamento
	var dir = (get_global_mouse_position() - global_position).normalized()
	var ratio = clamp(charge_duration / max_charge_time, 0, 1)

	# speed_factor entre 20% e 100%
	var speed_factor = lerp(0.2, 1.0, ratio)

	# dispara, passando só o speed_factor
	arrow.pm.set_direction(dir, speed_factor)




func get_current_charge_duration() -> float:
	return Time.get_ticks_msec() / 1000.0 - charge_start_time

func update_bow_ui() -> void:
	if is_charging:
		var percent = int(clamp(get_current_charge_duration() / max_charge_time, 0, 1) * 100)
		bow_force_label.text = "Força: %d%%" % percent
	else:
		bow_force_label.text = ""

func give_bow() -> void:
	has_bow = true
	print("🏹 Arco coletado!")
	if bow_sprite:
		bow_sprite.visible = true

func update_step_sound() -> void:
	if is_moving():
		emit_step_sound()
	else:
		deactivate_step_sound()

func emit_step_sound() -> void:
	if step_sound_pulse == null or not is_instance_valid(step_sound_pulse):
		create_step_sound_pulse()
	else:
		update_step_sound_pulse()

func create_step_sound_pulse() -> void:
	step_sound_pulse = sound_pulse_scene.instantiate() as Area2D
	add_child(step_sound_pulse)
	step_sound_pulse.position = Vector2.ZERO
	step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))

func update_step_sound_pulse() -> void:
	step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))

func deactivate_step_sound() -> void:
	if step_sound_pulse != null and is_instance_valid(step_sound_pulse):
		step_sound_pulse.deactivate()

func _on_player_died() -> void:
	die()

func die() -> void:
	print("💀 player morreu")
	PlayerController.switch_current_player()
	queue_free()
