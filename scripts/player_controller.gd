# PlayerController.gd
extends Node

signal player_changed(player: Node)

static var current_player: Node = null

func set_current_player(player: Node) -> void:
	current_player = player
	emit_signal("player_changed", player)
	print("Selected player: ", player.name)

func switch_current_player() -> void:
	var main = get_tree().get_root().get_node("Main")
	if main and main.has_method("switch_current_player"):
		main.switch_current_player()
