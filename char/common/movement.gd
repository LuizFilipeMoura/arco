extends Node2D
var hexUtil := HexUtil.new()
@export var hex_available: Texture2D
@export var movement_radius := 1
@onready var parent = get_parent()
var hex_sprite: Sprite2D
var current_cell_draw := Vector2.ZERO
var current_cell_move := Vector2.ZERO

var cells_in_radius_draw: Array
var cells_in_radius_move: Array

signal move_to(pos: Vector2)

func _ready(): 
	draw_available_cells_sprite2()
	parent.connect("finished_move", Callable(self, "draw_available_cells_sprite2"))

func draw_available_cells_sprite2():
	# 1) limpa os sprites antigos
	for c in get_children():
		c.queue_free()

	# 2) pega a posição mundial do Player e converte pro espaço do grid
	var player_global = get_parent().global_position
	var player_local  = to_local(player_global)
	current_cell_draw = hexUtil.pixel_to_cell(player_local)
	current_cell_move = hexUtil.pixel_to_cell(get_parent().global_position)

	cells_in_radius_draw = hexUtil.cells_in_radius(current_cell_draw, movement_radius)
	cells_in_radius_move = hexUtil.cells_in_radius(current_cell_move, movement_radius)

	print("player_global:", player_global, "→ player_local:", player_local, "→ current_cell:", current_cell_draw)

	# 3) desenha um sprite em cada célula do raio
	var cells = hexUtil.cells_in_radius(current_cell_draw, movement_radius)
	for cell in cells:
		var center = hexUtil.cell_to_pixel(cell)
		var s = Sprite2D.new()
		s.texture        = hex_available
		s.modulate       = Color(1, 1, 1, 0.5)
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.position       = center
		s.centered       = true
		s.z_index        = 1
		add_child(s)



func start_movement(pos: Vector2):
	var cell = hexUtil.pixel_to_cell(pos)
	# só prossegue se for uma célula permitida
	if cell in cells_in_radius_move:
		print("Destino tudo certo:", cell)
		var center = hexUtil.cell_to_pixel(cell)
		emit_signal("move_to", center)
	else:
		print("Destino não está dentro do raio de movimento:", cell)
