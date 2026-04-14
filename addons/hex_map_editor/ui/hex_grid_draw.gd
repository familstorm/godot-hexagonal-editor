@tool
extends Control

var map_data: HexMapData

signal painted(q: int, r: int)

func _ready() -> void:
    custom_minimum_size = Vector2(2000, 1000)
    # Allows it to receive input
    focus_mode = Control.FOCUS_ALL

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            var local_pos = event.position
            # Center of the 2000x1000 control is (1000, 500)
            var origin_offset = Vector2(1000, 500)
            var hex_coord = HexMath.pixel_to_hex(local_pos - origin_offset)
            painted.emit(hex_coord.x, hex_coord.y)
            queue_redraw()
    
    # Support drag painting
    elif event is InputEventMouseMotion:
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            var local_pos = event.position
            var origin_offset = Vector2(1000, 500)
            var hex_coord = HexMath.pixel_to_hex(local_pos - origin_offset)
            painted.emit(hex_coord.x, hex_coord.y)
            queue_redraw()

func _draw() -> void:
    # 1. Draw Background
    var rect = Rect2(0, 0, 2000, 1000)
    # Background color base, or texture
    if map_data and map_data.background_texture:
        draw_texture_rect(map_data.background_texture, rect, false)
    else:
        # Default placeholder background
        draw_rect(rect, Color(0.15, 0.15, 0.15))
        
    # 2. Draw Hexagons
    if not map_data:
        return
        
    var origin_offset = Vector2(1000, 500)
    
    for cell in map_data.cells:
        var core_corners = HexMath.get_hex_corners(cell.q, cell.r)
        
        # Translate to center of rect
        var offset_corners = PackedVector2Array()
        for c in core_corners:
            offset_corners.append(c + origin_offset)
            
        var base_color = Color(0.3, 0.3, 0.3, 0.5)
        var edge_color = Color(0, 0, 0, 1.0)
        
        # Terrain Colors
        if cell.terrain_type == HexCell.TerrainType.PLAN:
            base_color = Color(0.7, 0.7, 0.7, 0.7) # Xám trắng
        elif cell.terrain_type == HexCell.TerrainType.WATER:
            base_color = Color(0.2, 0.4, 0.8, 0.7) # Xanh dương
        elif cell.terrain_type == HexCell.TerrainType.WALL:
            base_color = Color(0.4, 0.4, 0.4, 0.7) # Xám
        elif cell.terrain_type == HexCell.TerrainType.CAPITAL:
            base_color = Color(1.0, 1.0, 1.0, 1.0) # Trắng tinh
            
        draw_colored_polygon(offset_corners, base_color)
        
        # Draw outlines
        var points_with_loop = offset_corners.duplicate()
        points_with_loop.append(offset_corners[0]) # close loop
        draw_polyline(points_with_loop, edge_color, 2.0)
