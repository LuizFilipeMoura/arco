class_name Enemy
extends CharacterBody2D

# === RENDERIZAÇÃO DE VISÃO ===
@export var vision_renderer: Polygon2D
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var vision_cone2D = $VisionCone2D
@export var alert_color: Color

# === CONFIGURAÇÕES ===
@export var max_health: int = 3
@export var bullet_scene: PackedScene
@export var bullet_speed: float = 400.0
@export var bullet_damage: int = 1
@export var fire_interval: float = 1.0  # intervalo entre tiros em segundos
@onready var fire_timer: Timer = Timer.new()

# === REFERÊNCIAS DE NÓS ===
@onready var sound_sensor: SoundSensor = $SoundSensor
@onready var enemy_sprite: Sprite2D    = $Sprite2D
@onready var health_label: Label       = $HealthLabel
@onready var health_manager            = $HealthManagement

# === ESTADOS ===
var flip_direction: bool = false
var detection_label: Label
var is_on_patrol := false
var player_in_sight : Player


func _ready() -> void:
	setup_sound_sensor()
	setup_detection_label()
	setup_flip_timer()
	setup_fire_timer()

	# Configuração de vida
	health_manager.max_health = max_health
	health_manager.connect("damaged", Callable(self, "_on_health_damaged"))
	health_manager.connect("died", Callable(self, "_on_enemy_died"))
	_on_health_damaged(0)


func setup_sound_sensor() -> void:
	sound_sensor.connect("sound_heard", Callable(self, "_on_sound_heard"))

func setup_detection_label() -> void:
	detection_label = get_tree().root.get_node("Main/CanvasLayer/DetectionLabel")
	detection_label.text = ""
	detection_label.visible = false

func setup_flip_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(Callable(self, "_flip_direction"))
	add_child(timer)

func setup_fire_timer() -> void:
	fire_timer.wait_time = fire_interval
	fire_timer.one_shot = false
	fire_timer.autostart = false
	fire_timer.timeout.connect(Callable(self, "_on_fire_timeout"))
	add_child(fire_timer)

func _flip_direction() -> void:
	if not is_on_patrol:
		return
	flip_direction = not flip_direction
	scale.x *= -1

func _on_health_damaged(amount: int) -> void:
	SoundPulse.spawn(get_tree().current_scene, 250, global_position, 1)
	update_health_label()

func _on_enemy_died() -> void:
	SoundPulse.spawn(get_tree().current_scene, randf_range(1000, 1500), global_position, 1)
	queue_free()

func update_health_label() -> void:
	if health_label:
		health_label.text = "%d / %d" % [health_manager.current_health, health_manager.max_health]

func _process(delta):
	if player_in_sight:
		rotate_vision_cone(player_in_sight.global_position)

func rotate_vision_cone(position): 
	var dir_sound = (position - global_position).normalized()
	vision_cone2D.rotation = dir_sound.angle() - 1.6

func _on_sound_heard(sound_pos: Vector2) -> void:
	if player_in_sight: return
	# Dispara uma vez na direção do som
	# rotaciona o cone de visão (Polygon2D) para apontar ao som
	rotate_vision_cone(sound_pos)
	show_detection("🔉 SOM DETECTADO")

func _on_fire_timeout() -> void:
	print("fire timeout")
	if player_in_sight:
		shoot_at_target(player_in_sight.global_position)

func shoot_at_target(target_pos: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position

	var dir = (target_pos - global_position).normalized()
	bullet.pm.set_direction(dir, 1.0)
	bullet.pm.damage = bullet_damage

func show_detection(texto: String) -> void:
	detection_label.text = texto
	detection_label.visible = true


func _on_vision_cone_area_body_entered(body):
	if not player_in_sight:
		player_in_sight = body as Player
	vision_renderer.color = alert_color
	is_on_patrol = false
	show_detection("🔍 ALVO DETECTADO")
	if fire_timer.is_stopped():
		fire_timer.start()


func _on_vision_cone_area_body_exited(body):
	player_in_sight = null
	vision_renderer.color = original_color
	pass # Replace with function body.
