extends Area2D

@export var pickup_sound: AudioStreamPlayer2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.name == "Player":
		if body.has_method("give_bow"):
			body.give_bow()
			if pickup_sound:
				pickup_sound.play()
			queue_free()
