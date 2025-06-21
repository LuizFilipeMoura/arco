# Bullet.gd
extends Area2D
class_name Bullet

@onready var pm: ProjectileManagement = $ProjectileManagement

func _ready() -> void:
	# Timer para destruir o projétil...
	var timer = Timer.new()
	timer.wait_time = pm.lifetime
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(Callable(self, "queue_free"))
	add_child(timer)

func set_direction(dir: Vector2, speed_value: float) -> void:
	# Define direção e velocidade via manager
	pm.set_direction(dir, speed_value)
