# res://Scripts/Player/Player.gd
extends StaticBody2D

var hexUtil := HexUtil.new()
var canvasLayer: CanvasLayer
@onready var movement = $Movement
signal finished_move
func _ready():
	# 1) Cria o CanvasLayer como IRMÃO do Player (não filho)
	MouseInputManager.connect("left_mouse_pressed",  Callable(self, "_on_left_mouse_pressed"))
	MouseInputManager.connect("left_mouse_released", Callable(self, "_on_left_mouse_released"))
	MouseInputManager.connect("right_mouse_pressed", Callable(self, "_on_right_mouse_pressed"))
	singal_setup()
	
func singal_setup():
	movement.connect("move_to", Callable(self, "on_move_to"))
	
func on_move_to(pos):
	global_position = pos
	emit_signal("finished_move")

func _on_left_mouse_pressed(pos: Vector2):	# teleportar Player para o centro do hex clicado
	var world_pos = get_global_mouse_position()
	$Movement.start_movement(world_pos)

func _on_left_mouse_released(pos: Vector2):
	executar_acao(pos)

func _on_right_mouse_pressed(pos: Vector2):
	abrir_menu_contexto(pos)

func _on_mouse_moved(delta: Vector2):
	atualizar_cursor(delta)

# Métodos de exemplo (implemente conforme sua lógica)
func selecionar_alvo(cell: Vector2) -> void:
	pass

func executar_acao(pos: Vector2) -> void:
	pass

func abrir_menu_contexto(pos: Vector2) -> void:
	pass

func atualizar_cursor(delta: Vector2) -> void:
	pass
