class_name Enemy
# Enemy.gd
extends CharacterBody2D

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

# === ESTADOS ===
var current_health: int
var flip_direction: bool = false
var detection_label: Label
var is_on_patrol := true

# === FUNÇÕES DE CICLO ===
func _ready():
	setup_health()
	setup_vision()
	setup_sound_sensor()
	setup_detection_label()
	setup_flip_timer()

# === SETUP ===
func setup_health():
	current_health = max_health
	update_health_label()

func setup_vision():
	vision_area.connect("body_entered", Callable(self, "_on_vision_area_body_entered"))

func setup_sound_sensor():
	sound_sensor.connect("sound_heard", Callable(self, "_on_sound_heard"))

func setup_detection_label():
	detection_label = get_tree().root.get_node("Main/CanvasLayer/DetectionLabel")
	detection_label.text    = ""
	detection_label.visible = false

func setup_flip_timer():
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(Callable(self, "_flip_direction"))
	add_child(timer)

# === FLIP / DIREÇÃO ===
func _flip_direction():
	if not is_on_patrol: return
	flip_direction = !flip_direction
	self.scale.x *= -1

# === VIDA ===
func take_damage(amount: int):
	current_health -= amount
	SoundPulse.spawn(get_tree().current_scene, randf_range(1000, 1500), global_position, 1)
	print("💥 inimigo atingido! vida: ", current_health)
	update_health_label()
	if current_health <= 0:
		die()

func die():
	queue_free()

func update_health_label():
	if health_label:
		health_label.text = str(current_health, " / ", max_health)

# === DETECÇÃO VIA VISÃO ===
func _on_vision_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		has_spotted_enemy(body.global_position)

# === DETECÇÃO VIA SOM ===
func _on_sound_heard(sound_pos: Vector2) -> void:
	has_spotted_enemy(sound_pos)

# === FUNÇÃO UNIFICADA DE DETECÇÃO ===
func has_spotted_enemy(position: Vector2) -> void:
	# Dispara no alvo detectado
	is_on_patrol = false
	shoot_at_target(position)
	# Exibe mensagem de detecção
	show_detection("🔍 ALVO DETECTADO em " + str(position))
	# Vira o inimigo para o ponto de detecção
	look_at(position)
	# Aqui você pode trocar o estado do inimigo para perseguir ou outra lógica de AI

# === PROJÉTIL ===
func shoot_at_target(target_pos: Vector2) -> void:
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.velocity = (target_pos - global_position).normalized() * bullet_speed
		bullet.damage = bullet_damage
		get_tree().current_scene.add_child(bullet)

# === EXIBIÇÃO DE DETECÇÃO ===
func show_detection(texto: String) -> void:
	detection_label.text    = texto
	detection_label.visible = true
