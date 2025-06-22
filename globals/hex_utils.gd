extends Resource
class_name HexUtil

# Flat-topped hexagon utility (axial coordinates)
@export var cell_size: Vector2 = Vector2(16, 16.25)

const SQRT3 = sqrt(3.0)
const HALF = 0.5
const THIRD = 1.0 / 3.0

# Neighbor directions in axial coords (flat-topped)
const NEIGHBORS = [
	Vector2(1, 0), Vector2(1, -1), Vector2(0, -1),
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)
]

# Convert axial cell (q, r) to pixel position
func cell_to_pixel(cell: Vector2) -> Vector2:
	var x = cell_size.x * (1.5 * cell.x)
	var y = cell_size.y * (SQRT3 * (cell.y + cell.x * HALF))
	return Vector2(x, y)

# Convert pixel position to axial cell coords
func pixel_to_cell(pos: Vector2) -> Vector2:
	var px = pos.x / cell_size.x
	var py = pos.y / cell_size.y
	var q = (2.0 / 3.0) * px
	var r = (-1.0 / 3.0) * px + THIRD * SQRT3 * py
	# Round via cube coords
	var cq = round(q)
	var cr = round(r)
	var cs = round(-q - r)
	var dq = abs(cq - q)
	var dr = abs(cr - r)
	var ds = abs(cs - (-q - r))
	if dq > dr and dq > ds:
		cq = -cr - cs
	elif dr > ds:
		cr = -cq - cs
	return Vector2(cq, cr)

# Distance (in steps) between two cells
func distance(a: Vector2, b: Vector2) -> int:
	var da = a - b
	var dq = da.x
	var dr = da.y
	var ds = -dq - dr
	return int((abs(dq) + abs(dr) + abs(ds)) / 2)

# Get the neighbor at index 0..5
func neighbor(cell: Vector2, dir: int) -> Vector2:
	return cell + NEIGHBORS[dir % NEIGHBORS.size()]

# Get all cells within 'radius' steps around 'cell', including the cell itself
func cells_in_radius(cell: Vector2, radius: int) -> Array:
	var results = []
	for dq in range(-radius, radius + 1):
		for dr in range(max(-radius, -dq - radius), min(radius, -dq + radius) + 1):
			results.append(cell + Vector2(dq, dr))
	return results
