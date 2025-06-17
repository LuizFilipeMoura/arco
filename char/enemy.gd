extends CharacterBody2D

@onready var vision_area = $VisionArea
@onready var vision_sprite = $VisionArea/Sprite2D
@onready var enemy_sprite = $Sprite2D
@export var max_health:int = 3
@onready var health_label:Label = $HealthLabel

var current_health:int
var flip_direction = false
var detection_label: Label

func _ready():
	current_health = max_health
	update_health_label()
	# Conectando o sinal do Area2D para detectar o jogador
	vision_area.body_entered.connect(_on_vision_area_body_entered)

	# Timer para inverter direção a cada 5 segundos
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_flip_direction)
	add_child(timer)

	# Procura o Label da cena principal
	detection_label = get_tree().root.get_node("Main/CanvasLayer/DetectionLabel")
	detection_label.text = ""
	detection_label.visible = false


func _flip_direction():
	flip_direction = !flip_direction
	self.scale.x *= -1
	
func take_damage(amount:int):
	current_health -= amount
	print("💥 inimigo atingido! vida: ", current_health)
	update_health_label()

	if current_health <= 0:
		die()
		
func die():
	queue_free()

func update_health_label():
	if health_label:
		health_label.text = str(current_health, " / ", max_health)
		
func _on_vision_area_body_entered(body):
	if body.name == "Player":
		detection_label.text = "🚨 DETECTADO!"
		detection_label.visible = true
