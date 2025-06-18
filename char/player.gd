extends CharacterBody2D

@export var speed: float = 500.0
@onready var bow_sprite: Sprite2D = $BowSprite # Se você tiver um Sprite do arco visível no corpo
@onready var bow_force_label:Label = $BowForceLabel

var has_bow: bool = false
var is_charging: bool = false
var charge_start_time: float = 0.0
var step_sound_timer:float = 0.0
var step_sound_pulse:Area2D = null

@export var arrow_scene: PackedScene
@export var min_force: float = 300.0
@export var max_force: float = 1000.0
@export var max_charge_time:float = 1.5
@export var sound_pulse_scene:PackedScene
@export var step_sound_min_radius:float = 50.0
@export var step_sound_max_radius:float = 100.0
@export var step_sound_interval:float = 0.3  # tempo entre passos


func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Normaliza para evitar andar mais rápido na diagonal
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()
	
func _unhandled_input(event):
	if has_bow:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					is_charging = true
					charge_start_time = Time.get_ticks_msec() / 1000.0
				else:
					is_charging = false
					var charge_duration = Time.get_ticks_msec() / 1000.0 - charge_start_time
					shoot_arrow(charge_duration)
					
					
func shoot_arrow(charge_duration:float):
	var arrow = arrow_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(arrow)

	arrow.global_position = global_position

	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	var force = lerp(min_force, max_force, clamp(charge_duration / max_charge_time, 0, 1))
	arrow.set_direction(direction, force)
	
func _process(delta):
	if is_moving():
		# Emitir/atualizar SoundPulse
		if step_sound_pulse == null or not is_instance_valid(step_sound_pulse):
			step_sound_pulse = sound_pulse_scene.instantiate() as Area2D
			add_child(step_sound_pulse)
			step_sound_pulse.position = Vector2.ZERO
			step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))
		else:
			step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))
	else:
		# Se parou de andar → desativa pulse
		if step_sound_pulse != null and is_instance_valid(step_sound_pulse):
			step_sound_pulse.deactivate()
			
	if is_charging:
		var current_time = Time.get_ticks_msec() / 1000.0
		var charge_duration = current_time - charge_start_time
		var charge_ratio = clamp(charge_duration / max_charge_time, 0, 1)
		var percent = int(charge_ratio * 100)
		bow_force_label.text = "Força: " + str(percent) + "%"
	else:
		bow_force_label.text = ""
		
func is_moving() -> bool:
	return velocity.length() > 0.1
	
func emit_step_sound():
	if step_sound_pulse == null or not is_instance_valid(step_sound_pulse):
		step_sound_pulse = sound_pulse_scene.instantiate() as Area2D
		add_child(step_sound_pulse)
		step_sound_pulse.position = Vector2.ZERO
		step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))
	else:
		# atualiza o target_radius enquanto anda
		step_sound_pulse.set_radius(randf_range(step_sound_min_radius, step_sound_max_radius))

	
	
func give_bow():
	has_bow = true
	print("🏹 Arco coletado!")

	# Se tiver um Sprite2D de arco nas costas, exibe agora
	if bow_sprite:
		bow_sprite.visible = true
