extends Node2D
var hexUtil := HexUtil.new()
func _ready(): 
	print("Canvas")

	# 2) Gera uma Label no centro de cada célula [-10,-10] a [10,10]
	for x in range(-10, 11):
		for y in range(-10, 11):
			var cell   = Vector2(x, y)
			var center = hexUtil.cell_to_pixel(cell)

			var label = Label.new()
			label.scale *= 0.5

			add_child(label)
			label.text = "%d,%d" % [x, y]

			# Ajusta o tamanho mínimo e centraliza o pivô
			var size = label.get_minimum_size()
			label.set_custom_minimum_size(size)
			label.position     = Vector2(center.x-6, center.y-15)

	# 3) Conecta os sinais de input
