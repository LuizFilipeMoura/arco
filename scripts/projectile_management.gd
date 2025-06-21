extends Node2D
class_name ProjectileManagement

@export var speed: float = 400.0            # velocidade base do projétil
@export var lifetime: float = 5.0
@export var deceleration: float = 200.0     # desaceleração (u/s²)
@export var min_speed_threshold: float = 20.0  # destrói abaixo disso

# pega o RigidBody2D pai
@onready var body: RigidBody2D = get_parent() as RigidBody2D

var damage: float = 0.0

func _ready() -> void:
	body.contact_monitor = true
	body.max_contacts_reported = 10
	body.connect("body_entered", Callable(self, "_on_body_entered"))

	# timer de vida
	await get_tree().create_timer(lifetime).timeout
	_cleanup()

func _physics_process(delta: float) -> void:
	body.linear_velocity = body.linear_velocity.move_toward(Vector2.ZERO, deceleration * delta)

	# destrói se muito lento
	if body.linear_velocity.length() <= min_speed_threshold:
		_cleanup()

func set_direction(dir: Vector2, speed_factor: float) -> void:
	# calcula velocidade final
	var dir_norm = dir.normalized()
	var applied_speed = speed * speed_factor
	body.linear_velocity = dir_norm * applied_speed

	# rotaciona o Node2D (sprite) para apontar
	body.rotation = dir_norm.angle()

	# dano = velocidade aplicada / velocidade base
	damage = applied_speed / speed

func _on_body_entered(collider: Node) -> void:
	_apply_damage(collider)
	_cleanup()


func _apply_damage(target: Node) -> void:
	# HealthManagement ou método genérico
	print("target", target)
	var hm = target.get_node_or_null("HealthManagement")
	if hm and hm.has_method("damage"):
		hm.damage(damage)
	elif target.has_method("take_damage"):
		target.take_damage(damage)

func _cleanup() -> void:
	get_parent().queue_free()
