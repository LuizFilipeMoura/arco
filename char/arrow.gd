extends Area2D

# === CONFIGURAÇÕES ===
@export var base_speed: float = 1500.0  # velocidade base da flecha
@export var deceleration_start_distance: float = 100.0
@export var deceleration_rate: float = 3000.0
@export var lifetime: float = 3.0
@export var min_velocity_before_despawn: float = 10.0
@export var base_damage: float = 1.0

# === ESTADOS ===
var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var initial_speed: float = 0.0
var fire_force: float = 1.0  # força para dano

# === CICLO DE VIDA ===
func _ready():
	setup_signals()
	start_lifetime_timer()

func _process(delta: float):
	move_arrow(delta)
	check_deceleration(delta)
	check_min_velocity()

# === SETUP ===
func setup_signals():
	connect("area_entered", Callable(self, "_on_area_entered"))

func start_lifetime_timer():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# === MOVIMENTO ===
func move_arrow(delta: float):
	var move = velocity * delta
	position += move
	distance_traveled += move.length()

func check_deceleration(delta: float):
	if distance_traveled > deceleration_start_distance:
		var slowdown = deceleration_rate * delta
		var current_speed = velocity.length()
		current_speed = max(current_speed - slowdown, 0)
		velocity = direction * current_speed

func check_min_velocity():
	# só checar depois de andar um pouco
	if distance_traveled < 10.0:
		return

	if velocity.length() < min_velocity_before_despawn:
		queue_free()

# === INTERFACE EXTERNA ===
func set_direction(dir: Vector2, arrow_speed: float, force_multiplier: float):
	direction = dir.normalized()
	fire_force = force_multiplier
	velocity = direction * arrow_speed
	initial_speed = velocity.length()
	rotation = direction.angle() + deg_to_rad(90)

# === COLISÃO ===
func _on_area_entered(area: Area2D):
	if not is_valid_target(area):
		return

	var enemy = area.get_parent()
	var current_damage = calculate_damage()
	apply_damage(enemy, current_damage)
	queue_free()

func is_valid_target(area: Area2D) -> bool:
	return area.name == "DamageHitbox"

func calculate_damage() -> float:
	var damage = base_damage * fire_force
	if damage < 1 : damage = 1
	print("Arrow hit! Damage: ", damage)
	return damage

func apply_damage(enemy: Node, damage: float):
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
