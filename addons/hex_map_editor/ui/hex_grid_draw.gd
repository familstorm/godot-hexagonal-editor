@tool
extends Control

var map_data: HexMapData

var pan_offset: Vector2 = Vector2(250, 150)
var zoom: float = 1.0
var is_panning: bool = false

signal painted(q: int, r: int)

func _ready() -> void:
	custom_minimum_size = Vector2(2000, 1000)
	focus_mode = Control.FOCUS_ALL

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Panning controls
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
			else:
				is_panning = false
		
		# Zoom controls
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_point(1.1, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_point(0.9, event.position)
			
		# Painting
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var local_pos = (event.position - pan_offset) / zoom
				var hex_coord = HexMath.pixel_to_hex(local_pos)
				painted.emit(hex_coord.x, hex_coord.y)
				queue_redraw()
	
	elif event is InputEventMouseMotion:
		if is_panning:
			pan_offset += event.relative
			queue_redraw()
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var local_pos = (event.position - pan_offset) / zoom
			var hex_coord = HexMath.pixel_to_hex(local_pos)
			painted.emit(hex_coord.x, hex_coord.y)
			queue_redraw()

func _zoom_at_point(factor: float, point: Vector2) -> void:
	var old_zoom = zoom
	zoom = clamp(zoom * factor, 0.2, 5.0)
	var diff = point - pan_offset
	pan_offset += diff - (diff * (zoom / old_zoom))
	queue_redraw()

func _draw() -> void:
	if not map_data:
		return
		
	# Mọi thứ được vẽ sau lệnh này sẽ tự động zoom và pan theo toạ độ ảo!
	draw_set_transform(pan_offset, 0.0, Vector2(zoom, zoom))
	
	# Tính toán kích thước nền ảo để debug, mặc định bắt đầu từ (-80, -40).
	# Tính logic BG x,y width height sẽ do Main_panel thông báo.
	if map_data.background_texture:
		var tex_size = map_data.background_texture.get_size()
		# Offset ảnh lùi về góc top-left của ma trận Hex lưới
		draw_texture_rect(map_data.background_texture, Rect2(Vector2(-80, -40), tex_size), false)

	for cell in map_data.cells:
		var core_corners = HexMath.get_hex_corners(cell.q, cell.r)
		
		var base_color = Color(0.3, 0.3, 0.3, 0.5)
		var edge_color = Color(0, 0, 0, 1.0)
		
		if cell.terrain_type == HexCell.TerrainType.PLACEHOLDER:
			base_color = Color(0.8, 0.8, 0.8, 0.1) # Translucent placeholder
			edge_color = Color(0.5, 0.5, 0.5, 0.5) # Gray dashed look equivalent
		elif cell.terrain_type == HexCell.TerrainType.PLAN:
			base_color = Color(0.7, 0.7, 0.7, 0.7)
		elif cell.terrain_type == HexCell.TerrainType.WATER:
			base_color = Color(0.2, 0.4, 0.8, 0.7) # Xanh dương
		elif cell.terrain_type == HexCell.TerrainType.WALL:
			base_color = Color(0.4, 0.4, 0.4, 0.7) # Xám
		elif cell.terrain_type == HexCell.TerrainType.CAPITAL:
			base_color = Color(1.0, 1.0, 1.0, 1.0) # Trắng tinh
			
		draw_colored_polygon(core_corners, base_color)
		
		var points_with_loop = core_corners.duplicate()
		points_with_loop.append(core_corners[0])
		# Zoom line thickness normalization
		draw_polyline(points_with_loop, edge_color, max(1.0, 2.0 / zoom))
