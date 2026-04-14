@tool
class_name HexCell
extends Resource

enum TerrainType {
	VISIBLE = 0,
	HIDDEN = 1,
	UNWALKABLE = 2,
	WATER = 3
}

@export var q: int = 0
@export var r: int = 0
@export var terrain_type: TerrainType = TerrainType.VISIBLE
@export var custom_properties: Dictionary = {}

func _init(_q: int = 0, _r: int = 0) -> void:
	q = _q
	r = _r
