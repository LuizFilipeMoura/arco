# Bullet.gd
extends Area2D
class_name Bullet

@export var speed: float = 4.0
@export var damage: int = 1
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	setup_signals()
	# Conecta o sinal de colisão pela área
	# Timer para remover bullet depois de 5 segundos
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(Callable(self, "queue_free"))
	add_child(timer)
	
func setup_signals():
	connect("area_entered", Callable(self, "_on_area_entered"))
	
func _physics_process(delta: float) -> void:
	# Move o projétil manualmente
	position += velocity * delta

func _on_area_entered(hurtboxArea: Node) -> void:
	# Aplica dano se atingir um player
	if hurtboxArea.is_in_group("Player"):
		print("_on_area_entered", hurtboxArea)
		var player: Player = hurtboxArea.get_parent()
		print("Player", player)
		player.take_damage(damage)
	# Destroi o projétil após a colisão
		queue_free()
