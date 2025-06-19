extends Node2D

@onready var active_label: Label = $CanvasLayer/ActivePlayerLabel

func _ready():
	PlayerController.player_changed.connect(Callable(self, "_on_player_changed"))
	PlayerController.set_current_player($Player1)

func _process(delta):
	if Input.is_action_just_pressed("select_player_1"):
		PlayerController.set_current_player($Player1)
	if Input.is_action_just_pressed("select_player_2"):
		PlayerController.set_current_player($Player2)

func _on_player_changed(player):
	for p in get_tree().get_nodes_in_group("Player"):
		if p == player:
			p.modulate = Color(1, 1, 1)
		else:
			p.modulate = Color(0.5, 0.5, 0.5)
