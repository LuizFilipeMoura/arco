# Arrow.gd
extends Area2D
class_name Arrow

@export var deceleration_start_distance: float = 100.0
@export var deceleration_rate: float = 3000.0
@export var min_velocity_before_despawn: float = 10.0
@export var base_damage: float = 1.0
@export var lifetime: float = 3.0

@onready var pm: ProjectileManagement = $ProjectileManagement

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var fire_force: float = 1.0

func _ready() -> void:
	# Destrói após lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_direction(dir: Vector2, arrow_speed: float, force_multiplier: float) -> void:
	direction = dir.normalized()
	fire_force = force_multiplier
	distance_traveled = 0.0
	rotation = direction.angle() + deg_to_rad(90)
	# Configura manager
	pm.set_direction(direction, arrow_speed)
	pm.damage = max(base_damage * fire_force, 1)

func _physics_process(delta: float) -> void:
	# Atualiza distância percorrida
	distance_traveled += pm.velocity.length() * delta
	# Desaceleração
	if distance_traveled > deceleration_start_distance:
		var slowdown = deceleration_rate * delta
		var current_speed = pm.velocity.length()
		current_speed = max(current_speed - slowdown, 0)
		pm.velocity = direction * current_speed
	# Destrói se lento demais
	if distance_traveled > 10.0 and pm.velocity.length() < min_velocity_before_despawn:
		queue_free()
