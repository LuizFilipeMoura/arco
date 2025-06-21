extends Camera2D

@export var camera_speed: float = 5.0
@export var deadzone_radius: float = 16.0

func _process(delta):
	if PlayerController.current_player != null:
		var target_pos = PlayerController.current_player.global_position
		var distance = global_position.distance_to(target_pos)

		if distance > deadzone_radius:
			global_position = global_position.lerp(target_pos, camera_speed * delta)
