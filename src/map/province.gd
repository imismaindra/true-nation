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

# Fasilitas yang terpasang di provinsi ini (BuildingType int -> level int)
var buildings: Dictionary = {}
var stationed_units: Array = []

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	_setup_polygon_geometry()
	update_visuals()

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

func get_center() -> Vector2:
	if polygon_points.is_empty():
		return Vector2.ZERO
	var sum = Vector2.ZERO
	for pt in polygon_points:
		sum += pt
	return sum / float(polygon_points.size())

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
	
	# Efek Hover & Seleksi
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
