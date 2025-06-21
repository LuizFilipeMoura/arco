# ProjectileManagement.gd
extends Node2D
class_name ProjectileManagement

@export var damage: int = 1
@export var speed: float = 400.0
@export var lifetime: float = 5.0

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Conecta sinal de colisão do pai
	get_parent().connect("area_entered", Callable(self, "_on_parent_area_entered"))
	# Destrói após lifetime
	await get_tree().create_timer(lifetime).timeout
	get_parent().queue_free()

func _physics_process(delta: float) -> void:
	# Movimenta projétil
	get_parent().position += velocity * delta

func set_direction(dir: Vector2, speed_value: float) -> void:
	velocity = dir.normalized() * speed_value

func _on_parent_area_entered(area: Area2D) -> void:
	var character = area.get_parent()
	var hm = character.get_node_or_null("HealthManagement")
	if hm and hm.has_method("damage"):
		hm.damage(damage)
	elif character.has_method("take_damage"):
		character.take_damage(damage)
	# Remove projétil
	get_parent().queue_free()
