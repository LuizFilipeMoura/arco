# res://Scripts/Player/Player.gd
extends StaticBody2D

var hexUtil := HexUtil.new()
var canvasLayer: CanvasLayer

func _ready():
	# 1) Cria o CanvasLayer como IRMÃO do Player (não filho)

	MouseInputManager.connect("left_mouse_pressed",  Callable(self, "_on_left_mouse_pressed"))
	MouseInputManager.connect("left_mouse_released", Callable(self, "_on_left_mouse_released"))
	MouseInputManager.connect("right_mouse_pressed", Callable(self, "_on_right_mouse_pressed"))

func _on_left_mouse_pressed(pos: Vector2):
	# teleportar Player para o centro do hex clicado
	var world_pos = get_global_mouse_position()
	print("World pos", world_pos)
	var cell      = hexUtil.pixel_to_cell(world_pos)
	print("Cell", cell)
	var center    = hexUtil.cell_to_pixel(cell)
	global_position = center
	selecionar_alvo(cell)

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
