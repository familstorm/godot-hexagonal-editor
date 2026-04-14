class_name HexMath
extends RefCounted

# Các hàm dựa trên thuật toán Flat-Top Hexagon của Red Blob Games
# Đã được thiết kế lại để bóp dẹp (Scale dọc) cho đúng kích thước Isometric 160x80

static func hex_to_pixel(q: int, r: int) -> Vector2:
	var x = 120.0 * q
	var y = 40.0 * q + 80.0 * r
	return Vector2(x, y)

static func pixel_to_hex(pos: Vector2) -> Vector2i:
	var fq = pos.x / 120.0
	var fr = (-pos.x / 3.0 + pos.y) / 80.0
	var fs = -fq - fr
	return cube_round(fq, fr, fs)

static func cube_round(frac_q: float, frac_r: float, frac_s: float) -> Vector2i:
	var q = roundi(frac_q)
	var r = roundi(frac_r)
	var s = roundi(frac_s)
	
	var q_diff = absf(q - frac_q)
	var r_diff = absf(r - frac_r)
	var s_diff = absf(s - frac_s)
	
	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
		
	return Vector2i(q, r)

# Trả về 6 đỉnh của một ô hex tại toạ độ q,r
static func get_hex_corners(q: int, r: int) -> PackedVector2Array:
	var center = hex_to_pixel(q, r)
	var corners = PackedVector2Array()
	# Vẽ theo chiều kim đồng hồ bắt đầu từ phải
	corners.append(center + Vector2(80.0, 0.0))
	corners.append(center + Vector2(40.0, 40.0))
	corners.append(center + Vector2(-40.0, 40.0))
	corners.append(center + Vector2(-80.0, 0.0))
	corners.append(center + Vector2(-40.0, -40.0))
	corners.append(center + Vector2(40.0, -40.0))
	return corners
