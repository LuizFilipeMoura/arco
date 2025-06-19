# Main.gd
extends Node2D

var players: Array = []
var current_index: int = 0

func _ready() -> void:
	# Inicializa lista de jogadores
	players = [$Player1, $Player2]
	PlayerController.player_changed.connect(Callable(self, "_on_player_changed"))
	# Seleciona primeiro jogador vivo
	players = players.filter(func(p): return p != null and p.is_inside_tree())
	if players.size() > 0:
		PlayerController.set_current_player(players[0])

func _process(delta: float) -> void:
	# Limpa jogadores removidos
	players = players.filter(func(p): return p != null and p.is_inside_tree())
	# Seleção manual por input
	if Input.is_action_just_pressed("select_player_1") and players.size() > 0:
		current_index = 0
		PlayerController.set_current_player(players[0])
	if Input.is_action_just_pressed("select_player_2") and players.size() > 1:
		current_index = 1
		PlayerController.set_current_player(players[1])

func switch_current_player() -> void:
	# Itera jogadores até encontrar um vivo
	var count = players.size()
	for i in range(count):
		current_index = (current_index + 1) % count
		var candidate = players[current_index]
		if candidate and candidate.is_inside_tree():
			PlayerController.set_current_player(candidate)
			return
	print("Nenhum jogador válido para alternar")

func _on_player_changed(player: Node) -> void:
	# Atualiza modulate apenas em jogadores vivos
	for p in players:
		if p and p.is_inside_tree():
			if p == player:
				p.modulate = Color(1, 1, 1)
			else:
				p.modulate = Color(0.5, 0.5, 0.5)
