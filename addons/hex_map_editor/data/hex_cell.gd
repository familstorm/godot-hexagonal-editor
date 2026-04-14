@tool
class_name HexCell
extends Resource

enum TerrainType {
	PLAN = 1,      # Xám trắng
	WATER = 2,     # Xanh dương
	WALL = 3,      # Xám
	CAPITAL = 4    # Trắng
}

@export var q: int = 0
@export var r: int = 0
@export var terrain_type: TerrainType = TerrainType.PLAN
@export var custom_properties: Dictionary = {}

func _init(_q: int = 0, _r: int = 0) -> void:
	q = _q
	r = _r

func to_dict() -> Dictionary:
	return {
		"q": q,
		"r": r,
		"type": terrain_type,
		"custom": custom_properties
	}

func from_dict(data: Dictionary) -> void:
	q = int(data.get("q", 0))
	r = int(data.get("r", 0))
	terrain_type = int(data.get("type", TerrainType.PLAN)) as TerrainType
	custom_properties = data.get("custom", {})

