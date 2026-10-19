# military_manager.gd
# Mengelola seluruh divisi militer di peta, seleksi unit, dan pemrosesan perintah pergerakan.
class_name MilitaryManager
extends Node2D

@export var map_manager: Node2D
@export var player_country: Country

signal unit_selection_changed(unit: MilitaryUnit)

var units: Array[MilitaryUnit] = []
var selected_unit: MilitaryUnit = null

@onready var units_container: Node2D = $Units

func _ready() -> void:
	_collect_units()

func _collect_units() -> void:
	units.clear()
	for child in units_container.get_children():
		if child is MilitaryUnit:
			_register_unit(child)

func _register_unit(unit: MilitaryUnit) -> void:
	if not units.has(unit):
		units.append(unit)
		if not unit.clicked.is_connected(_on_unit_clicked):
			unit.clicked.connect(_on_unit_clicked)

func spawn_unit(unit_data: UnitData, owner_c: Country, target_province: Province) -> MilitaryUnit:
	if units_container == null:
		units_container = get_node_or_null("Units")
		if units_container == null:
			units_container = self
	var unit_scene = preload("res://src/military/unit.tscn")
	var unit_inst = unit_scene.instantiate() as MilitaryUnit
	unit_inst.unit_data = unit_data
	unit_inst.owner_country = owner_c
	unit_inst.current_province = target_province
	unit_inst.position = target_province.get_center() + target_province.position
	units_container.add_child(unit_inst)
	_register_unit(unit_inst)
	print("🎖️ UNIT BARU DI-DEPLOY: %s di %s (%s)" % [
		unit_data.unit_name, target_province.province_name, owner_c.country_name
	])
	return unit_inst

func _on_unit_clicked(unit: Node2D) -> void:
	var mil_unit = unit as MilitaryUnit
	if mil_unit == null:
		return
	
	# Hanya bisa memilih unit milik negara pemain
	if mil_unit.owner_country != player_country:
		return
	
	if selected_unit == mil_unit:
		return
	
	deselect_current_unit()
	
	selected_unit = mil_unit
	selected_unit.set_selected(true)
	unit_selection_changed.emit(selected_unit)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.unit_selected.emit(selected_unit)

func deselect_current_unit() -> void:
	if selected_unit != null:
		selected_unit.set_selected(false)
		selected_unit = null
		unit_selection_changed.emit(null)
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus != null:
			event_bus.unit_deselected.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or not event.is_pressed():
		return
	
	# Klik Kanan: Perintah Gerak Unit ke Provinsi yang dituju
	if event.button_index == MOUSE_BUTTON_RIGHT and selected_unit != null:
		var target_prov = _get_province_under_mouse()
		if target_prov != null:
			var success = selected_unit.order_move_to(target_prov)
			if success:
				print("Perintah gerak: %s -> %s" % [selected_unit.unit_data.unit_name, target_prov.province_name])
			get_viewport().set_input_as_handled()
		else:
			# Klik kanan di luar provinsi membatalkan seleksi
			deselect_current_unit()
	
	# Klik Kiri di area kosong membatalkan seleksi unit
	elif event.button_index == MOUSE_BUTTON_LEFT:
		var unit_under_mouse = _get_unit_under_mouse()
		var prov_under_mouse = _get_province_under_mouse()
		if unit_under_mouse == null and prov_under_mouse == null:
			deselect_current_unit()

func _get_province_under_mouse() -> Province:
	if map_manager == null:
		return null
	var mouse_world_pos = get_global_mouse_position()
	for prov in map_manager.provinces:
		if Geometry2D.is_point_in_polygon(mouse_world_pos - prov.position, prov.polygon_points):
			return prov
	return null

func _get_unit_under_mouse() -> MilitaryUnit:
	var mouse_world_pos = get_global_mouse_position()
	for unit in units:
		if unit.global_position.distance_to(mouse_world_pos) <= 30.0:
			return unit
	return null
