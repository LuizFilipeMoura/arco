extends Area2D

@export var speed:float = 800.0								# velocidade base
@export var deceleration_start_distance:float = 100.0		# distância antes de desacelerar
@export var deceleration_rate:float = 3000.0					# força de desaceleração
@export var lifetime:float = 3.0								# tempo de vida da flecha
@export var min_velocity_before_despawn:float = 10.0			# mata a flecha se ficar muito lenta

var velocity:Vector2 = Vector2.ZERO
var direction:Vector2 = Vector2.ZERO
var distance_traveled:float = 0.0

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	set_process(true)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta:float):
	var move = velocity * delta
	position += move
	distance_traveled += move.length()

	if distance_traveled > deceleration_start_distance:
		var slowdown = deceleration_rate * delta
		var current_speed = velocity.length()
		current_speed = max(current_speed - slowdown, 0)
		velocity = direction * current_speed

	if velocity.length() < min_velocity_before_despawn:
		queue_free()
		
func set_direction(dir:Vector2, force_multiplier:float):
	direction = dir.normalized()
	velocity = direction * speed * force_multiplier
	rotation = direction.angle() + deg_to_rad(90)
	
func _on_area_entered(area:Area2D):
	if(area.name != "DamageHitbox"): return
	var enemy = area.get_parent()
	print("area", area)
	if enemy.has_method("take_damage"):
		enemy.take_damage(1)
		queue_free()
