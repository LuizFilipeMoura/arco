# SoundSensor.gd
extends Area2D
class_name SoundSensor

signal sound_heard(global_pos)

# Distância máxima que o sensor “ouve”
@export var hearing_range := 200.0
@onready var shape_node := $CollisionShape2D
@onready var sprite    := $Sprite2D

func _ready() -> void:
	setup_signals()
	_update_hearing_range()

	
	# === SETUP ===
func setup_signals():
	connect("area_entered", Callable(self, "_on_area_entered"))
	# (opcional) ajustar CollisionShape2D para hearing_range

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("SoundPulse"):
		# emite a posição do pulse para o inimigo reagir
		emit_signal("sound_heard", area.global_position)
		
func _update_hearing_range() -> void:
	# 1) Atualiza o raio do CollisionShape2D
	var circle_shape = shape_node.shape as CircleShape2D
	circle_shape.radius = hearing_range

	# 2) Escala o Sprite para cobrir o diâmetro = hearing_range * 2
	if sprite.texture:
		var tex_size = sprite.texture.get_size()
		# evitar divisão por zero
		if tex_size.x > 0 and tex_size.y > 0:
			var diameter = hearing_range * 2.0
			sprite.scale = Vector2(
				diameter / tex_size.x,
				diameter / tex_size.y
			)
		
func set_hearing_range(new_range: float) -> void:
	hearing_range = new_range
	_update_hearing_range()
