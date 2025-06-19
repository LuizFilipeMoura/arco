# PlayerController.gd
extends Node

var current_player: CharacterBody2D = null
signal player_changed(player)

func set_current_player(player):
	current_player = player
	emit_signal("player_changed", player)
	print("Selected player: ", player.name)
