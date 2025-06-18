extends CharacterBody2D

# === CONFIGURAÇÕES ===
@export var max_health: int = 3

# === REFERÊNCIAS DE NÓS ===
@onready var vision_area: Area2D = $VisionArea
@onready var vision_sprite: Sprite2D = $VisionArea/Sprite2D
@onready var enemy_sprite: Sprite2D = $Sprite2D
@onready var health_label: Label = $HealthLabel

# === ESTADOS ===
var current_health: int
var flip_direction: bool = false
var detection_label: Label

# === FUNÇÕES DE CICLO ===
func _ready():
	setup_health()
	setup_vision()
	setup_flip_timer()
	setup_detection_label()

# === SETUP ===
func setup_health():
	current_health = max_health
	update_health_label()

func setup_vision():
	vision_area.body_entered.connect(_on_vision_area_body_entered)

func setup_flip_timer():
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_flip_direction)
	add_child(timer)

func setup_detection_label():
	detection_label = get_tree().root.get_node("Main/CanvasLayer/DetectionLabel")
	detection_label.text = ""
	detection_label.visible = false

# === FLIP / DIREÇÃO ===
func _flip_direction():
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

# === DETECÇÃO ===
func _on_vision_area_body_entered(body):
	if body.name == "Player":
		show_detection()

func show_detection():
	detection_label.text = "🚨 DETECTADO!"
	detection_label.visible = true
