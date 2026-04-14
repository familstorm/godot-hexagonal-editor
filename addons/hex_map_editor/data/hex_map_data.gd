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

func remove_cell(q: int, r: int) -> void:
	for i in range(cells.size() - 1, -1, -1):
		if cells[i].q == q and cells[i].r == r:
			cells.remove_at(i)
			return

func clear_cells() -> void:
	cells.clear()

func to_dict() -> Dictionary:
	var cells_data = []
	for cell in cells:
		cells_data.append(cell.to_dict())
	var dict = {
		"cells": cells_data
	}
	if background_texture and background_texture.resource_path:
		dict["bg_path"] = background_texture.resource_path
	return dict

func from_dict(data: Dictionary) -> void:
	cells.clear()
	var cells_data = data.get("cells", [])
	for c_data in cells_data:
		var cell = HexCell.new()
		cell.from_dict(c_data)
		cells.append(cell)
		
	if data.has("bg_path"):
		var bg_path = data["bg_path"]
		if ResourceLoader.exists(bg_path):
			background_texture = ResourceLoader.load(bg_path)
		else:
			background_texture = null
	else:
		background_texture = null

