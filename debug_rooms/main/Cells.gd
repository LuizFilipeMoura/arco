extends Node2D
var hexUtil := HexUtil.new()
@export var hover_texture: Texture2D
var hover_sprite: Sprite2D
var hovered_cell := Vector2.ZERO

func _ready(): 
	hover_sprite = Sprite2D.new()
	hover_sprite.texture = hover_texture
	hover_sprite.centered = true
	hover_sprite.visible = false
	hover_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(hover_sprite)

func _process(delta):
	var world_pos = get_global_mouse_position()
	var cell = hexUtil.pixel_to_cell(world_pos)
	if cell != hovered_cell:
		hovered_cell = cell
		# 4) Reposiciona e mostra o sprite
		var center = hexUtil.cell_to_pixel(cell)
		hover_sprite.position = center
		hover_sprite.visible = true
