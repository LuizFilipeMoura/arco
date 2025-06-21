extends Area2D

# === CONFIGURAÇÕES ===
@export var pickup_sound: AudioStreamPlayer2D

# === CICLO DE VIDA ===
func _ready():
	setup_signals()

# === SETUP ===
func setup_signals():
	connect("body_entered", Callable(self, "_on_body_entered"))

# === INTERAÇÕES ===
func _on_body_entered(body: Node):
	if not is_player(body):
		return

	give_bow_to_player(body)
	play_pickup_sound()
	spawn_pickup_sound_pulse()

	queue_free()

func is_player(body: Node) -> bool:
	return body.is_in_group("Player")

func give_bow_to_player(player: Node):
	if player.has_method("give_bow"):
		player.give_bow()

func play_pickup_sound():
	if pickup_sound:
		pickup_sound.play()

func spawn_pickup_sound_pulse():
	SoundPulse.spawn(get_tree().current_scene, randf_range(500, 700), global_position, 0.5)
