@tool
extends HBoxContainer

var sidebar: VBoxContainer
var scroll_container: ScrollContainer
var grid_draw: Control
var map_data: HexMapData

var input_cols: SpinBox
var input_rows: SpinBox
var lbl_bg_info: Label
var bg_picker: EditorResourcePicker

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
	
	_create_brush_button("Brush: Erase Hex (-1)", -1)
	_create_brush_button("Brush: Placeholder", HexCell.TerrainType.PLACEHOLDER)
	_create_brush_button("Brush: Plan (X.trắng)", HexCell.TerrainType.PLAN)
	_create_brush_button("Brush: Water (Xanh)", HexCell.TerrainType.WATER)
	_create_brush_button("Brush: Wall (Xám)", HexCell.TerrainType.WALL)
	_create_brush_button("Brush: Capital (Trắng)", HexCell.TerrainType.CAPITAL)

	sidebar.add_child(HSeparator.new())

	var btn_save = Button.new()
	btn_save.text = "Save Map (.json)"
	btn_save.pressed.connect(_on_save_pressed)
	sidebar.add_child(btn_save)

	var btn_load = Button.new()
	btn_load.text = "Load Map (.json)"
	btn_load.pressed.connect(_on_load_pressed)
	sidebar.add_child(btn_load)
	
	sidebar.add_child(HSeparator.new())
	
	var btn_clear = Button.new()
	btn_clear.text = "Clear Grid"
	btn_clear.pressed.connect(_on_clear_pressed)
	sidebar.add_child(btn_clear)
	
	sidebar.add_child(HSeparator.new())
	
	var lbl_bg = Label.new()
	lbl_bg.text = "Background Image:"
	sidebar.add_child(lbl_bg)
	
	bg_picker = EditorResourcePicker.new()
	bg_picker.base_type = "Texture2D"
	bg_picker.resource_changed.connect(_on_bg_picked)
	sidebar.add_child(bg_picker)
	
	sidebar.add_child(HSeparator.new())
	
	# Inputs cho Cols, Rows
	var hbox_cols = HBoxContainer.new()
	var lbl_cols = Label.new()
	lbl_cols.text = "Cols:"
	input_cols = SpinBox.new()
	input_cols.min_value = 1
	input_cols.max_value = 1000
	input_cols.value = 25
	hbox_cols.add_child(lbl_cols)
	hbox_cols.add_child(input_cols)
	sidebar.add_child(hbox_cols)
	
	var hbox_rows = HBoxContainer.new()
	var lbl_rows = Label.new()
	lbl_rows.text = "Rows:"
	input_rows = SpinBox.new()
	input_rows.min_value = 1
	input_rows.max_value = 1000
	input_rows.value = 20
	hbox_rows.add_child(lbl_rows)
	hbox_rows.add_child(input_rows)
	sidebar.add_child(hbox_rows)
	
	lbl_bg_info = Label.new()
	lbl_bg_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_bg_info.modulate = Color(0.6, 0.8, 1.0)
	lbl_bg_info.text = "BG Size Info: "
	sidebar.add_child(lbl_bg_info)

	var btn_generate = Button.new()
	btn_generate.text = "Generate Grid"
	btn_generate.pressed.connect(_on_generate_pressed)
	sidebar.add_child(btn_generate)
	
	var lbl_help = Label.new()
	lbl_help.text = "Controls:\n- L-Click: Draw\n- R-Click/Mid: Pan Map\n- Scroll: Zoom"
	lbl_help.modulate = Color(0.7, 0.7, 0.7)
	sidebar.add_child(lbl_help)

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

func _update_bg_info(width: int, height: int):
	var req_width = 120 * (width - 1) + 160
	var req_height = 80 * (height - 1) + 80
	lbl_bg_info.text = "Trải Grid %dx%d ô.\nBạn hãy chèn ảnh Background kích thước tương đối: %d x %d px" % [width, height, req_width, req_height]

func _init_empty_map():
	map_data.clear_cells()
	var width = int(input_cols.value)
	var height = int(input_rows.value)
	
	for col in range(width):
		var col_offset = int(floor(col / 2.0))
		for row in range(-col_offset, height - col_offset):
			var cell = HexCell.new(col, row)
			cell.terrain_type = HexCell.TerrainType.PLACEHOLDER
			map_data.add_or_update_cell(col, row, cell)
			
	_update_bg_info(width, height)

func _on_bg_picked(resource: Resource):
	map_data.background_texture = resource as Texture2D
	grid_draw.queue_redraw()

func _on_hex_painted(q: int, r: int):
	if brush_type == -1:
		map_data.remove_cell(q, r)
	else:
		var cell = HexCell.new(q, r)
		cell.terrain_type = brush_type as HexCell.TerrainType
		map_data.add_or_update_cell(q, r, cell)

func _on_save_pressed():
	var save_path = "res://test_hex_map.json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data_dict = map_data.to_dict()
		data_dict["cols"] = int(input_cols.value)
		data_dict["rows"] = int(input_rows.value)
		
		var json_str = JSON.stringify(data_dict, "\t")
		file.store_string(json_str)
		file.close()
		print("HexMapEditor: Saved json map to ", save_path)
	else:
		print("HexMapEditor: Failed to save map to JSON")

func _on_load_pressed():
	var save_path = "res://test_hex_map.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_str = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_str)
		if error == OK:
			map_data.from_dict(json.data)
			if json.data.has("cols"):
				input_cols.value = float(json.data["cols"])
			if json.data.has("rows"):
				input_rows.value = float(json.data["rows"])
			
			bg_picker.edited_resource = map_data.background_texture
			
			_update_bg_info(int(input_cols.value), int(input_rows.value))
			grid_draw.map_data = map_data
			grid_draw.queue_redraw()
			print("HexMapEditor: Loaded json map from ", save_path)
		else:
			print("HexMapEditor: JSON Parse Error: ", json.get_error_message())
	else:
		print("HexMapEditor: Map file not found at ", save_path)

func _on_clear_pressed():
	map_data.clear_cells()
	grid_draw.queue_redraw()
	
func _on_generate_pressed():
	_init_empty_map()
	grid_draw.queue_redraw()
