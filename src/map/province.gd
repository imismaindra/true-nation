# province.gd
# Node wilayah teritorial interaktif dengan visual poligon, border, hover, dan seleksi.
class_name Province
extends Area2D

enum TerrainType {
	PLAINS,
	HILLS,
	MOUNTAINS,
	URBAN,
	COASTAL,
	SEA_ZONE
}

@export_group("Identity")
@export var province_id: String = "prov_01"
@export var province_name: String = "Wilayah Barat"
@export var terrain: TerrainType = TerrainType.PLAINS
@export var owner_country: Country
@export var connected_provinces: Array[Province] = []

@export_group("Economy & Population")
@export var base_money_output: float = 25.0
@export var base_steel_output: float = 5.0
@export var base_fuel_output: float = 2.0
@export var population: int = 750000

@export_group("Visual Polygon")
@export var polygon_points: PackedVector2Array = PackedVector2Array()

# Node anak internal
@onready var visual_polygon: Polygon2D = $VisualPolygon
@onready var border_line: Line2D = $BorderLine
@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D
@onready var label_name: Label = $LabelName

var is_hovered: bool = false
var is_selected: bool = false

# Fasilitas yang terpasang di provinsi ini
@export var initial_buildings: Array[BuildingData] = []
var buildings: Array[BuildingData] = []
var max_building_slots: int = 4
var stationed_units: Array = []

func _ready() -> void:
	buildings = initial_buildings.duplicate()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	_setup_polygon_geometry()
	update_visuals()

func has_building(b_type: BuildingData.BuildingType) -> bool:
	for b in buildings:
		if b != null and b.building_type == b_type:
			return true
	return false

func has_building_id(b_id: String) -> bool:
	for b in buildings:
		if b != null and b.building_id == b_id:
			return true
	return false

func get_building_count(b_type: BuildingData.BuildingType) -> int:
	var count: int = 0
	for b in buildings:
		if b != null and b.building_type == b_type:
			count += 1
	return count

func add_building(b_data: BuildingData) -> bool:
	if b_data == null:
		return false
	if buildings.size() >= max_building_slots:
		return false
	buildings.append(b_data)
	return true

func remove_building(b_data: BuildingData) -> bool:
	var idx = buildings.find(b_data)
	if idx != -1:
		buildings.remove_at(idx)
		return true
	return false

func get_defense_bonus() -> float:
	var total: float = 0.0
	for b in buildings:
		if b != null:
			total += b.defense_bonus_percent
	return total

func has_fortification() -> bool:
	return get_building_count(BuildingData.BuildingType.FORTIFICATION) > 0

func has_naval_base() -> bool:
	return has_building(BuildingData.BuildingType.NAVAL_DOCKYARD)

func has_airbase() -> bool:
	return has_building(BuildingData.BuildingType.AIRBASE)

func can_construct_building(b_data: BuildingData) -> Dictionary:
	if b_data == null:
		return { "can": false, "reason": "Data bangunan tidak valid." }
	if is_sea_zone():
		return { "can": false, "reason": "Tidak bisa mendirikan bangunan di zona perairan laut." }
	if buildings.size() >= max_building_slots:
		return { "can": false, "reason": "Slot bangunan penuh (%d/%d)." % [buildings.size(), max_building_slots] }
	if b_data.requires_coastal and terrain != TerrainType.COASTAL:
		return { "can": false, "reason": "Hanya dapat dibangun di wilayah pesisir pantai (Coastal)." }
	return { "can": true, "reason": "Bisa dibangun." }

func _setup_polygon_geometry() -> void:
	if polygon_points.size() >= 3:
		visual_polygon.polygon = polygon_points
		collision_shape.polygon = polygon_points
		
		# Set up border line yang menutup poligon
		var border_pts = polygon_points.duplicate()
		border_pts.append(polygon_points[0])
		border_line.points = border_pts
		
		# Tempatkan label di centroid/titik tengah poligon
		label_name.position = get_center() - (label_name.size * 0.5)
	
	label_name.text = province_name

var _visual_centroid: Vector2 = Vector2.ZERO

func get_center() -> Vector2:
	if _visual_centroid != Vector2.ZERO:
		return _visual_centroid
	_visual_centroid = _calculate_visual_centroid()
	return _visual_centroid

func _calculate_visual_centroid() -> Vector2:
	if polygon_points.is_empty():
		return Vector2.ZERO
	if polygon_points.size() < 3:
		return polygon_points[0]
	
	# 1. Formula momen luas poligon (Green's theorem centroid)
	var area_sum: float = 0.0
	var cx: float = 0.0
	var cy: float = 0.0
	var n = polygon_points.size()
	
	for i in range(n):
		var p1 = polygon_points[i]
		var p2 = polygon_points[(i + 1) % n]
		var cross = (p1.x * p2.y) - (p2.x * p1.y)
		area_sum += cross
		cx += (p1.x + p2.x) * cross
		cy += (p1.y + p2.y) * cross
	
	var total_area = area_sum * 0.5
	if abs(total_area) > 0.01:
		var candidate = Vector2(cx / (6.0 * total_area), cy / (6.0 * total_area))
		if Geometry2D.is_point_in_polygon(candidate, polygon_points):
			return candidate
	
	# 2. Fallback: Cari titik interior terbaik jika centroid momen berada di luar bentuk poligon
	var min_pt = polygon_points[0]
	var max_pt = polygon_points[0]
	for pt in polygon_points:
		min_pt.x = min(min_pt.x, pt.x)
		min_pt.y = min(min_pt.y, pt.y)
		max_pt.x = max(max_pt.x, pt.x)
		max_pt.y = max(max_pt.y, pt.y)
	
	var best_pt = Vector2.ZERO
	var max_dist = -1.0
	for step_y in range(1, 9):
		for step_x in range(1, 9):
			var test_pos = Vector2(
				lerpf(min_pt.x, max_pt.x, float(step_x) / 9.0),
				lerpf(min_pt.y, max_pt.y, float(step_y) / 9.0)
			)
			if Geometry2D.is_point_in_polygon(test_pos, polygon_points):
				var min_dist_to_edge = 999999.0
				for k in range(n):
					var p1 = polygon_points[k]
					var p2 = polygon_points[(k + 1) % n]
					var d = _distance_point_to_segment(test_pos, p1, p2)
					min_dist_to_edge = min(min_dist_to_edge, d)
				if min_dist_to_edge > max_dist:
					max_dist = min_dist_to_edge
					best_pt = test_pos
	
	if max_dist > 0.0:
		return best_pt
	
	return (min_pt + max_pt) * 0.5

func _distance_point_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var ab_len2 = ab.length_squared()
	if ab_len2 == 0.0:
		return p.distance_to(a)
	var t = clampf((p - a).dot(ab) / ab_len2, 0.0, 1.0)
	var proj = a + t * ab
	return p.distance_to(proj)

enum VisibilityState {
	VISIBLE,
	FOGGED,
	UNKNOWN
}

var current_visibility: VisibilityState = VisibilityState.VISIBLE

func set_visibility_state(new_state: VisibilityState) -> void:
	if current_visibility != new_state:
		current_visibility = new_state
		update_visuals()

func update_visuals() -> void:
	if not visual_polygon or not border_line:
		return
	
	var base_color: Color
	if is_sea_zone():
		base_color = Color(0.12, 0.28, 0.45, 0.65) # Biru laut transparan
	elif owner_country != null:
		base_color = owner_country.map_color
		base_color.a = 0.75
	else:
		base_color = Color(0.35, 0.35, 0.38, 0.7) # Netral / abu-abu
	
	match current_visibility:
		VisibilityState.VISIBLE:
			label_name.visible = true
			if is_selected:
				visual_polygon.color = base_color.lightened(0.25)
				border_line.default_color = Color(1.0, 0.9, 0.2, 1.0) # Kuning emas terang
				border_line.width = 4.0
				label_name.modulate = Color(1.0, 1.0, 0.4, 1.0)
			elif is_hovered:
				visual_polygon.color = base_color.lightened(0.15)
				border_line.default_color = Color(1.0, 1.0, 1.0, 0.9) # Putih terang
				border_line.width = 2.5
				label_name.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				visual_polygon.color = base_color
				if is_sea_zone():
					border_line.default_color = Color(0.25, 0.5, 0.75, 0.5)
				else:
					border_line.default_color = Color(0.1, 0.1, 0.12, 0.85)
				border_line.width = 1.5
				label_name.modulate = Color(0.9, 0.9, 0.9, 0.85)
		
		VisibilityState.FOGGED:
			# Wilayah pernah dikunjungi / diketahui, tapi tidak ada sensor aktif
			label_name.visible = true
			label_name.modulate = Color(0.65, 0.7, 0.8, 0.5)
			var fog_color = base_color.darkened(0.6).lerp(Color(0.1, 0.14, 0.2, 0.85), 0.7)
			if is_hovered or is_selected:
				visual_polygon.color = fog_color.lightened(0.15)
				border_line.default_color = Color(0.4, 0.5, 0.6, 0.7)
				border_line.width = 2.0
			else:
				visual_polygon.color = fog_color
				border_line.default_color = Color(0.12, 0.15, 0.2, 0.6)
				border_line.width = 1.2
		
		VisibilityState.UNKNOWN:
			# Belum pernah diintai (gelap gulita)
			label_name.visible = false
			if is_hovered:
				visual_polygon.color = Color(0.06, 0.08, 0.12, 0.98)
				border_line.default_color = Color(0.2, 0.25, 0.3, 0.5)
				border_line.width = 1.5
			else:
				visual_polygon.color = Color(0.04, 0.05, 0.08, 0.95)
				border_line.default_color = Color(0.08, 0.1, 0.14, 0.3)
				border_line.width = 1.0

func set_selected(val: bool) -> void:
	if is_selected != val:
		is_selected = val
		update_visuals()

func set_highlighted(val: bool) -> void:
	if is_hovered != val:
		is_hovered = val
		update_visuals()

func is_sea_zone() -> bool:
	return terrain == TerrainType.SEA_ZONE

func _on_mouse_entered() -> void:
	set_highlighted(true)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.province_hovered.emit(self)

func _on_mouse_exited() -> void:
	set_highlighted(false)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus != null:
			event_bus.province_clicked.emit(self)
		get_viewport().set_input_as_handled()

func get_terrain_name() -> String:
	match terrain:
		TerrainType.PLAINS: return "Dataran Rendah (Plains)"
		TerrainType.HILLS: return "Perbukitan (Hills)"
		TerrainType.MOUNTAINS: return "Pegunungan (Mountains)"
		TerrainType.URBAN: return "Metropolitan (Urban)"
		TerrainType.COASTAL: return "Pesisir Pantai (Coastal)"
		TerrainType.SEA_ZONE: return "Zona Laut (Sea Zone)"
		_: return "Daratan"
