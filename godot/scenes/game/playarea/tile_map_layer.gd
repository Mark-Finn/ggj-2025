extends TileMapLayer

@export var width: int = 10
@export var height: int = 20

func _ready():
	for y in range(height):
		for x in range(width):
			var vec := Vector2i.ZERO 
			if x == 0 && y == 0:
				vec = Vector2i(2, 1)
			elif x == width - 1 && y == 0:
				vec = Vector2i(2, 0)
			elif y == 0:
				vec = Vector2i(1, 0)
			elif x == width - 1:
				vec = Vector2i(1, 1)
			elif x == 0:
				vec = Vector2i(0, 1)
			var tile_id = 0
			set_cell(Vector2i(x, y), tile_id, vec)
