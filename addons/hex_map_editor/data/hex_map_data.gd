@tool
class_name HexMapData
extends Resource

@export var background_texture: Texture2D
@export var cells: Array[HexCell] = []

func get_cell_at(q: int, r: int) -> HexCell:
	for cell in cells:
		if cell.q == q and cell.r == r:
			return cell
	return null

func add_or_update_cell(q: int, r: int, cell_data: HexCell) -> void:
	var existing = get_cell_at(q, r)
	if existing:
		existing.terrain_type = cell_data.terrain_type
		existing.custom_properties = cell_data.custom_properties
	else:
		cells.append(cell_data)

func clear_cells() -> void:
	cells.clear()
