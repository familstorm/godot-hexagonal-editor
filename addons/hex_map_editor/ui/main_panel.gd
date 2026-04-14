@tool
extends HBoxContainer

var sidebar: VBoxContainer
var scroll_container: ScrollContainer
var grid_draw: Control
var map_data: HexMapData

var brush_type: int = 0

func _init() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL

	# Sidebar
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 0)
	add_child(panel)

	sidebar = VBoxContainer.new()
	panel.add_child(sidebar)

	var title = Label.new()
	title.text = "Hex Editor Toolbar"
	sidebar.add_child(title)
	
	_create_brush_button("Brush: Visible (Highlight)", HexCell.TerrainType.VISIBLE)
	_create_brush_button("Brush: Hidden (Dark)", HexCell.TerrainType.HIDDEN)
	_create_brush_button("Brush: Unwalkable (Red)", HexCell.TerrainType.UNWALKABLE)
	_create_brush_button("Brush: Water (Blue)", HexCell.TerrainType.WATER)

	sidebar.add_child(HSeparator.new())

	var btn_save = Button.new()
	btn_save.text = "Save Map (.tres)"
	btn_save.pressed.connect(_on_save_pressed)
	sidebar.add_child(btn_save)

	var btn_load = Button.new()
	btn_load.text = "Load Map (.tres)"
	btn_load.pressed.connect(_on_load_pressed)
	sidebar.add_child(btn_load)
	
	sidebar.add_child(HSeparator.new())
	
	var btn_clear = Button.new()
	btn_clear.text = "Clear Grid"
	btn_clear.pressed.connect(_on_clear_pressed)
	sidebar.add_child(btn_clear)
	
	var btn_generate = Button.new()
	btn_generate.text = "Generate Default Grid"
	btn_generate.pressed.connect(_on_generate_pressed)
	sidebar.add_child(btn_generate)

	# Scroll Area
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(scroll_container)
	
	var center = CenterContainer.new()
	center.size_flags_horizontal = SIZE_EXPAND_FILL
	center.size_flags_vertical = SIZE_EXPAND_FILL
	scroll_container.add_child(center)

	var GridDrawScript = preload("res://addons/hex_map_editor/ui/hex_grid_draw.gd")
	grid_draw = GridDrawScript.new()
	
	map_data = HexMapData.new()
	_init_empty_map()
	grid_draw.map_data = map_data
	grid_draw.painted.connect(_on_hex_painted)
	
	center.add_child(grid_draw)

func _create_brush_button(text: String, type: int):
	var btn = Button.new()
	btn.text = text
	btn.pressed.connect(func(): brush_type = type)
	sidebar.add_child(btn)

func _init_empty_map():
	map_data.clear_cells()
	# Tạo lưới hình chữ nhật 15x10 ô
	var width = 15
	var height = 10
	var hw = width / 2 # 7
	var hh = height / 2 # 5
	
	for col in range(-hw, width - hw):
		var col_offset = int(floor(col / 2.0))
		for row in range(-hh - col_offset, height - hh - col_offset):
			var cell = HexCell.new(col, row)
			# Mặc định hiển thị lưới để dễ thao tác ban đầu
			cell.terrain_type = HexCell.TerrainType.VISIBLE
			map_data.add_or_update_cell(col, row, cell)

func _on_hex_painted(q: int, r: int):
	# Update or add if missing
	var cell = HexCell.new(q, r)
	cell.terrain_type = brush_type as HexCell.TerrainType
	map_data.add_or_update_cell(q, r, cell)

func _on_save_pressed():
	var err = ResourceSaver.save(map_data, "res://test_hex_map.tres")
	if err == OK:
		print("HexMapEditor: Saved map to res://test_hex_map.tres")
	else:
		print("HexMapEditor: Failed to save map. Error code: ", err)

func _on_load_pressed():
	if ResourceLoader.exists("res://test_hex_map.tres"):
		map_data = ResourceLoader.load("res://test_hex_map.tres")
		grid_draw.map_data = map_data
		grid_draw.queue_redraw()
		print("HexMapEditor: Loaded map from res://test_hex_map.tres")
	else:
		print("HexMapEditor: Map file not found at res://test_hex_map.tres")

func _on_clear_pressed():
	map_data.clear_cells()
	grid_draw.queue_redraw()
	
func _on_generate_pressed():
	_init_empty_map()
	grid_draw.queue_redraw()
