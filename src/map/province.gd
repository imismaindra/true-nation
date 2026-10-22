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
@export var infrastructure_damage: float = 0.0 # 0..100 persen
@export var civilian_casualties: int = 0

@export_group("Visual Polygon")
@export var polygon_points: PackedVector2Array = PackedVector2Array()
@export var polygon_parts: Array = []

# Node anak internal
@onready var visual_polygon: Polygon2D = $VisualPolygon
@onready var border_line: Line2D = $BorderLine
@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D
@onready var label_name: Label = $LabelName

var is_hovered: bool = false
var is_selected: bool = false

var _extra_polygons: Array[Polygon2D] = []
var _extra_borders: Array[Line2D] = []

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

func get_output_multiplier() -> float:
	return clampf(1.0 - (infrastructure_damage / 100.0) * 0.8, 0.2, 1.0)

func get_repair_cost_money() -> int:
	return int(ceil(infrastructure_damage * 25.0))

func apply_war_damage(damage_pct: float, civ_casualties: int) -> void:
	infrastructure_damage = clampf(infrastructure_damage + damage_pct, 0.0, 100.0)
	if civ_casualties > 0:
		civilian_casualties += civ_casualties
		population = maxi(0, population - civ_casualties)

func repair_infrastructure() -> void:
	infrastructure_damage = 0.0

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

func _all_parts() -> Array:
	var parts: Array = []
	if polygon_points.size() >= 3:
		parts.append(polygon_points)
	for part in polygon_parts:
		if part is PackedVector2Array and part.size() >= 3:
			parts.append(part)
	return parts

func contains_point(point: Vector2) -> bool:
	if polygon_points.size() >= 3 and Geometry2D.is_point_in_polygon(point, polygon_points):
		return true
	for part in polygon_parts:
		if part is PackedVector2Array and part.size() >= 3:
			if Geometry2D.is_point_in_polygon(point, part):
				return true
	return false

func _closed_ring(ring: PackedVector2Array) -> PackedVector2Array:
	var pts = ring.duplicate()
	pts.append(ring[0])
	return pts

func _clear_extra_parts() -> void:
	for n in _extra_polygons:
		n.queue_free()
	for n in _extra_borders:
		n.queue_free()
	_extra_polygons.clear()
	_extra_borders.clear()

func _add_extra_part(part: PackedVector2Array) -> void:
	var poly := Polygon2D.new()
	poly.polygon = part
	poly.z_index = 0
	add_child(poly)
	_extra_polygons.append(poly)
	
	var ring := _closed_ring(part)
	var border := Line2D.new()
	border.points = ring
	border.z_index = 2
	border.joint_mode = border_line.joint_mode
	border.begin_cap_mode = border_line.begin_cap_mode
	border.end_cap_mode = border_line.end_cap_mode
	add_child(border)
	_extra_borders.append(border)

func _sync_extra_visuals() -> void:
	for p in _extra_polygons:
		p.color = visual_polygon.color
		p.visible = visual_polygon.visible
	for b in _extra_borders:
		b.default_color = border_line.default_color
		b.width = border_line.width
		b.visible = border_line.visible

func _setup_polygon_geometry() -> void:
	label_name.text = province_name
	label_name.reset_size()
	
	var parts := _all_parts()
	if parts.is_empty():
		return
	
	_clear_extra_parts()
	visual_polygon.z_index = 0
	border_line.z_index = 2
	label_name.z_index = 4
	
	var main_ring: PackedVector2Array = parts[0]
	var border_pts := _closed_ring(main_ring)
	visual_polygon.polygon = main_ring
	collision_shape.polygon = main_ring
	border_line.points = border_pts
	
	# Pulau-pulau tambahan dalam satu provinsi (MultiPolygon)
	for i in range(1, parts.size()):
		_add_extra_part(parts[i])
	
	# Tempatkan label di centroid/titik tengah poligon
	label_name.position = get_center() - (label_name.size * 0.5)

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
	
	# Penanganan khusus zona maritim / perairan laut
	if is_sea_zone():
		label_name.visible = true
		border_line.visible = false
		if is_selected:
			visual_polygon.color = Color(0.22, 0.62, 0.78, 0.14)
			label_name.modulate = Color(0.6, 0.95, 1.0, 1.0)
		elif is_hovered:
			visual_polygon.color = Color(0.18, 0.5, 0.68, 0.08)
			label_name.modulate = Color(0.7, 0.9, 1.0, 0.9)
		else:
			# Zona laut bebas tanpa garis kotak pembatas, biarkan samudra alami
			visual_polygon.color = Color(0, 0, 0, 0)
			label_name.modulate = Color(0.45, 0.75, 0.95, 0.55)
		_sync_extra_visuals()
		return
	
	# Penanganan daratan kepulauan
	border_line.visible = true
	var base_color: Color
	if owner_country != null:
		base_color = owner_country.map_color
		base_color.a = 0.85
	else:
		base_color = Color(0.28, 0.32, 0.38, 0.8) # Wilayah netral slate
	
	label_name.visible = true
	
	match current_visibility:
		VisibilityState.VISIBLE:
			if is_selected:
				visual_polygon.color = base_color.lightened(0.25)
				border_line.default_color = Color(1.0, 0.88, 0.2, 1.0) # Kuning emas terang
				border_line.width = 3.5
				label_name.modulate = Color(1.0, 1.0, 0.6, 1.0)
			elif is_hovered:
				visual_polygon.color = base_color.lightened(0.15)
				border_line.default_color = Color(1.0, 1.0, 1.0, 0.95)
				border_line.width = 2.5
				label_name.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				visual_polygon.color = base_color
				border_line.default_color = Color(0.06, 0.08, 0.12, 0.85)
				border_line.width = 1.5
				label_name.modulate = Color(0.95, 0.95, 0.95, 0.95)
		
		VisibilityState.FOGGED:
			# Wilayah diketahui namun tanpa sensor real-time: daratan tetap terlihat, hanya sedikit lebih teduh
			var fog_color = base_color.darkened(0.25)
			fog_color.a = 0.8
			if is_selected:
				visual_polygon.color = fog_color.lightened(0.2)
				border_line.default_color = Color(1.0, 0.88, 0.2, 0.85)
				border_line.width = 3.0
				label_name.modulate = Color(1.0, 1.0, 0.5, 0.9)
			elif is_hovered:
				visual_polygon.color = fog_color.lightened(0.12)
				border_line.default_color = Color(0.7, 0.8, 0.9, 0.8)
				border_line.width = 2.0
				label_name.modulate = Color(1.0, 1.0, 1.0, 0.95)
			else:
				visual_polygon.color = fog_color
				border_line.default_color = Color(0.08, 0.1, 0.14, 0.7)
				border_line.width = 1.2
				label_name.modulate = Color(0.9, 0.9, 0.9, 0.85)
		
		VisibilityState.UNKNOWN:
			# Shading taktis C4ISR: bentuk kepulauan tetap terlihat, tidak menjadi balok hitam pekat!
			var shroud_color = base_color.darkened(0.35).lerp(Color(0.12, 0.16, 0.24), 0.4)
			shroud_color.a = 0.75
			if is_selected:
				visual_polygon.color = shroud_color.lightened(0.2)
				border_line.default_color = Color(1.0, 0.88, 0.2, 0.8)
				border_line.width = 3.0
				label_name.modulate = Color(1.0, 1.0, 0.4, 0.9)
			elif is_hovered:
				visual_polygon.color = shroud_color.lightened(0.12)
				border_line.default_color = Color(0.4, 0.55, 0.7, 0.7)
				border_line.width = 2.0
				label_name.modulate = Color(1.0, 1.0, 1.0, 0.95)
			else:
				visual_polygon.color = shroud_color
				border_line.default_color = Color(0.08, 0.12, 0.18, 0.55)
				border_line.width = 1.0
				label_name.modulate = Color(0.85, 0.88, 0.92, 0.8)
	
	_sync_extra_visuals()

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
