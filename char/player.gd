class_name Player
extends CharacterBody2D

# === CONFIGURAÇÕES DO PLAYER ===
@export var speed: float = 500.0
@export var max_health: int = 5

# === CONFIGURAÇÕES DO ARCO ===
@export var arrow_scene: PackedScene
@export var max_charge_time: float = 1.5
@export var max_force_multiplier: float = 1.5  # máximo multiplicador de dano

# === CONFIGURAÇÕES DO PASSO / SOM ===
@export var sound_pulse_scene: PackedScene
@export var step_sound_min_radius: float = 50.0
@export var step_sound_max_radius: float = 100.0
@export var step_sound_interval: float = 0.3
@export var stop_velocity_threshold: float = 100.0

# === REFERÊNCIAS DE NÓS ===
@onready var bow_sprite: Sprite2D = $BowSprite
@onready var bow_force_label: Label = $BowForceLabel
@onready var health_label: Label = $HealthLabel

# === NAVEGAÇÃO ===
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var has_order: bool = false

# === ESTADOS ===
var has_bow: bool = false
var is_charging: bool = false
var charge_start_time: float = 0.0
var step_sound_pulse: Area2D = null
var current_health: int

# === CICLO DE FÍSICA ===
@export var stop_move_distance: float = 20.0
@export var stop_threshold_distance: float = 4.0

func _ready():
	# Aumenta o “tamanho” do agente para manter distância dos obstáculos dinâmicos
	nav_agent.radius = 32.0
	
	# Define até que distância ele “vê” outros agentes para desviar
	nav_agent.neighbor_distance = 64.0
	
	# Habilita avoidance (RVO) entre agentes
	nav_agent.avoidance_enabled = true
	nav_agent.avoidance_layers = 1  # ajuste para a layer de agentes
	nav_agent.avoidance_priority = 1.0
	
	current_health = max_health
	update_health_label()
	
func _process_order(delta: float) -> void:
	var next_pos = nav_agent.get_next_path_position()
	var to_next = next_pos - global_position
	var dist = to_next.length()

	# quando chegar perto o suficiente
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
	# limpa target pra não persistir erro
	nav_agent.target_position = global_position


# === CICLO DE PROCESSO NORMAL ===
func _process(delta: float) -> void:
	update_step_sound()
	update_bow_ui()
	
func _physics_process(delta: float) -> void:
	if has_order:
		_process_order(delta)
		
# === ENTRADA DO MOUSE ===
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if PlayerController.current_player == self:
			has_order = true
			nav_agent.target_position = get_global_mouse_position()
	if has_bow:
		handle_bow_input(event)

# === MOVIMENTO ===

func is_moving() -> bool:
	return velocity.length() > 0.1

# === ARCO ===
func handle_bow_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_charging()
		else:
			release_arrow()

func start_charging():
	is_charging = true
	charge_start_time = Time.get_ticks_msec() / 1000.0

func release_arrow():
	is_charging = false
	var charge_duration = get_current_charge_duration()
	shoot_arrow(charge_duration)

func shoot_arrow(charge_duration: float):
	var arrow = arrow_scene.instantiate() as Arrow
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = global_position

	var direction = (get_global_mouse_position() - global_position).normalized()
	var charge_ratio = clamp(charge_duration / max_charge_time, 0, 1)

	# Dano: de 0.0 até max_force_multiplier
	var force_multiplier = lerp(0.0, max_force_multiplier, charge_ratio)

	# Velocidade: flechas fracas ainda têm um mínimo de velocidade
	var speed_multiplier = lerp(0.2, 1.0, charge_ratio)
	var arrow_speed = arrow.base_speed * speed_multiplier

	# Lança a flecha
	arrow.set_direction(direction, arrow_speed, force_multiplier)
	arrow.base_damage = 1.5

func get_current_charge_duration() -> float:
	return Time.get_ticks_msec() / 1000.0 - charge_start_time

func update_bow_ui():
	if is_charging:
		var percent = int(clamp(get_current_charge_duration() / max_charge_time, 0, 1) * 100)
		bow_force_label.text = "Força: " + str(percent) + "%"
	else:
		bow_force_label.text = ""

func give_bow():
	has_bow = true
	print("🏹 Arco coletado!")
	if bow_sprite:
		bow_sprite.visible = true

# === SOM DE PASSOS ===
func update_step_sound():
	if is_moving():
		emit_step_sound()
	else:
		deactivate_step_sound()

func emit_step_sound():
	if step_sound_pulse == null or not is_instance_valid(step_sound_pulse):
		create_step_sound_pulse()
	else:
		update_step_sound_pulse()

func create_step_sound_pulse():
	step_sound_pulse = sound_pulse_scene.instantiate() as Area2D
	add_child(step_sound_pulse)
	step_sound_pulse.position = Vector2.ZERO
	step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))

func update_step_sound_pulse():
	step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))

func deactivate_step_sound():
	if step_sound_pulse != null and is_instance_valid(step_sound_pulse):
		step_sound_pulse.deactivate()
		
func take_damage(amount: int) -> void:
	print("take damange", amount)
	current_health -= amount
	update_health_label()
	print("💥 player atingido! vida: ", current_health)
	if current_health <= 0:
		die()
		
func die() -> void:
	print("💀 player morreu")
	# Troca para o próximo player
	PlayerController.switch_current_player()
	queue_free()

func update_health_label() -> void:
	if health_label:
		health_label.text = str(current_health, " / ", max_health)
