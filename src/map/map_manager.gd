# map_manager.gd
# Mengelola seluruh provinsi di peta, graf koneksi tetangga, dan rute jalur militer.
class_name MapManager
extends Node2D

@export var player_country: Country
@export var show_connection_lines: bool = true

var provinces: Array[Province] = []
var selected_province: Province = null

@onready var connections_container: Node2D = $Connections
@onready var provinces_container: Node2D = $Provinces

func _ready() -> void:
	_collect_provinces()
	_build_visual_connections()
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.province_clicked.connect(_on_province_clicked)

func _collect_provinces() -> void:
	provinces.clear()
	for child in provinces_container.get_children():
		if child is Province:
			provinces.append(child)

func _build_visual_connections() -> void:
	if not show_connection_lines or not connections_container:
		return
	
	# Bersihkan koneksi lama
	for child in connections_container.get_children():
		child.queue_free()
	
	var drawn_pairs = {}
	
	for prov in provinces:
		var center_a = prov.get_center() + prov.position
		for neighbor in prov.connected_provinces:
			if neighbor == null:
				continue
			
			var pair_key = "%s_%s" % [prov.province_id, neighbor.province_id]
			var reverse_key = "%s_%s" % [neighbor.province_id, prov.province_id]
			
			if drawn_pairs.has(pair_key) or drawn_pairs.has(reverse_key):
				continue
			drawn_pairs[pair_key] = true
			
			var center_b = neighbor.get_center() + neighbor.position
			
			# Garis rute antar provinsi
			var line = Line2D.new()
			line.points = PackedVector2Array([center_a, center_b])
			line.width = 2.0
			
			# Warna jalur: Biru jika antar zona laut, kuning gading jika antar daratan
			if prov.is_sea_zone() or neighbor.is_sea_zone():
				line.default_color = Color(0.3, 0.6, 0.9, 0.35) # Jalur pelayaran laut
			else:
				line.default_color = Color(0.9, 0.85, 0.6, 0.4) # Jalur jalan darat
			
			connections_container.add_child(line)

func _on_province_clicked(province: Province) -> void:
	if selected_province == province:
		# Klik provinsi yang sama tetap terpilih
		return
	
	# Deselect provinsi sebelumnya
	if selected_province != null:
		selected_province.set_selected(false)
	
	selected_province = province
	if selected_province != null:
		selected_province.set_selected(true)

func deselect_current_province() -> void:
	if selected_province != null:
		selected_province.set_selected(false)
		selected_province = null
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus != null:
			event_bus.province_clicked.emit(null)

func _unhandled_input(event: InputEvent) -> void:
	# Klik kanan di peta kosong membatalkan seleksi provinsi
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		deselect_current_province()
