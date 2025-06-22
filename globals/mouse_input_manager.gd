
extends Node

signal left_mouse_pressed(pos : Vector2)
signal left_mouse_released(pos : Vector2)
signal right_mouse_pressed(pos : Vector2)
signal right_mouse_released(pos : Vector2)
signal mouse_moved(delta : Vector2)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_mouse_click"):
			emit_signal("left_mouse_pressed", event.position)
		elif event.is_action_released("left_mouse_click"):
			emit_signal("left_mouse_released", event.position)
		elif event.is_action_pressed("right_mouse_click"):
			emit_signal("right_mouse_pressed", event.position)
		elif event.is_action_released("right_mouse_click"):
			emit_signal("right_mouse_released", event.position)

	elif event is InputEventMouseMotion:
		emit_signal("mouse_moved", event.relative)
