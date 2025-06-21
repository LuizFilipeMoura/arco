class_name Enemy
extends CharacterBody2D

# === RENDERIZAÇÃO DE VISÃO ===
@export var vision_renderer: Polygon2D
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@export var alert_color: Color

# === CONFIGURAÇÕES ===
@export var max_health: int = 3
@export var bullet_scene: PackedScene
@export var bullet_speed: float = 400.0
@export var bullet_damage: int = 1

# === REFERÊNCIAS DE NÓS ===
@onready var vision_area: Area2D       = $VisionArea
@onready var sound_sensor: SoundSensor = $SoundSensor
@onready var enemy_sprite: Sprite2D    = $Sprite2D
@onready var health_label: Label       = $HealthLabel
@onready var health_manager = $HealthManagement

# === ESTADOS ===
var flip_direction: bool = false
var detection_label: Label
var is_on_patrol := true

func _ready() -> void:
	setup_vision()
	setup_sound_sensor()
	setup_detection_label()
	setup_flip_timer()
	# HealthManagement
	health_manager.max_health = max_health
	health_manager.connect("damaged", Callable(self, "_on_health_damaged"))
	health_manager.connect("died",   Callable(self, "_on_enemy_died"))
	_on_health_damaged(0)

func setup_vision() -> void:
	pass

func setup_sound_sensor() -> void:
	sound_sensor.connect("sound_heard", Callable(self, "_on_sound_heard"))

func setup_detection_label() -> void:
	detection_label = get_tree().root.get_node("Main/CanvasLayer/DetectionLabel")
	detection_label.text    = ""
	detection_label.visible = false

func setup_flip_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot   = false
	timer.autostart  = true
	timer.timeout.connect(Callable(self, "_flip_direction"))
	add_child(timer)

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

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	vision_renderer.color = alert_color
	has_spotted_enemy(body.global_position)

func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	vision_renderer.color = original_color

func _on_sound_heard(sound_pos: Vector2) -> void:
	has_spotted_enemy(sound_pos)

func has_spotted_enemy(position: Vector2) -> void:
	is_on_patrol = false
	shoot_at_target(position)
	show_detection("🔍 ALVO DETECTADO em " + str(position))

func shoot_at_target(target_pos: Vector2) -> void:
	var bullet = bullet_scene.instantiate() as Bullet
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position

	# calcula direção
	var dir = (target_pos - global_position).normalized()
	# dispara pelo ProjectileManagement
	bullet.set_direction(dir, bullet.pm.speed)
	# configura dano no manager
	bullet.pm.damage = bullet_damage


func show_detection(texto: String) -> void:
	detection_label.text    = texto
	detection_label.visible = true
