# military_manager.gd
# Mengelola seluruh divisi militer di peta, seleksi unit, dan pemrosesan perintah pergerakan.
class_name MilitaryManager
extends Node2D

@export var map_manager: Node2D
@export var player_country: Country

signal unit_selection_changed(unit: MilitaryUnit)

var units: Array[MilitaryUnit] = []
var selected_unit: MilitaryUnit = null
var selected_units: Array[MilitaryUnit] = []

@onready var units_container: Node2D = $Units

func _ready() -> void:
	_collect_units()
	update_unit_formations()
	
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.hourly_tick.connect(func(_h, _d, _m, _y): update_unit_formations())

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
		if not unit.movement_completed.is_connected(_on_unit_movement_completed):
			unit.movement_completed.connect(_on_unit_movement_completed)

func _on_unit_movement_completed(_unit: Node2D, _prov: Province) -> void:
	update_unit_formations()

func update_unit_formations() -> void:
	var prov_units_map: Dictionary = {}
	for u in units:
		if u != null and is_instance_valid(u) and not u.is_moving and u.current_province != null:
			var p_id = u.current_province.province_id
			if not prov_units_map.has(p_id):
				prov_units_map[p_id] = []
			prov_units_map[p_id].append(u)
	
	for p_id in prov_units_map:
		var u_list: Array = prov_units_map[p_id]
		var count = u_list.size()
		if count == 1:
			u_list[0].formation_offset = Vector2.ZERO
		elif count == 2:
			u_list[0].formation_offset = Vector2(-24, 0)
			u_list[1].formation_offset = Vector2(24, 0)
		elif count == 3:
			u_list[0].formation_offset = Vector2(0, -22)
			u_list[1].formation_offset = Vector2(-26, 16)
			u_list[2].formation_offset = Vector2(26, 16)
		elif count == 4:
			u_list[0].formation_offset = Vector2(-24, -20)
			u_list[1].formation_offset = Vector2(24, -20)
			u_list[2].formation_offset = Vector2(-24, 20)
			u_list[3].formation_offset = Vector2(24, 20)
		else:
			var radius = 28.0 + (count * 2.5)
			for i in range(count):
				var angle = (float(i) / float(count)) * TAU
				u_list[i].formation_offset = Vector2(cos(angle), sin(angle)) * radius

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
	update_unit_formations()
	print("[UNIT DEPLOYED]: %s di %s (%s)" % [
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
	
	if selected_unit == mil_unit and selected_units.size() == 1:
		return
	
	deselect_all_units()
	
	selected_unit = mil_unit
	selected_units = [mil_unit]
	selected_unit.set_selected(true)
	unit_selection_changed.emit(selected_unit)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.unit_selected.emit(selected_unit)

func select_units_in_province(prov: Province) -> int:
	if prov == null or player_country == null:
		return 0
	
	deselect_all_units()
	
	for u in units:
		if u != null and is_instance_valid(u) and u.owner_country == player_country:
			if u.current_province == prov:
				u.set_selected(true)
				selected_units.append(u)
	
	if not selected_units.is_empty():
		selected_unit = selected_units[0]
		unit_selection_changed.emit(selected_unit)
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus != null:
			event_bus.unit_selected.emit(selected_unit)
		print("[CORPS] KORPS GABUNGAN: %d divisi dipilih di %s" % [selected_units.size(), prov.province_name])
	
	return selected_units.size()

func get_units_in_province(prov: Province, country: Country = null) -> Array[MilitaryUnit]:
	var result: Array[MilitaryUnit] = []
	for u in units:
		if u != null and is_instance_valid(u) and u.current_province == prov:
			if country == null or u.owner_country == country:
				result.append(u)
	return result

func deselect_current_unit() -> void:
	deselect_all_units()

func deselect_all_units() -> void:
	for u in selected_units:
		if u != null and is_instance_valid(u):
			u.set_selected(false)
	selected_units.clear()
	
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
	
	# Klik Kanan: Perintah Gerak Unit ke Provinsi yang dituju (Multi-Select Support)
	if event.button_index == MOUSE_BUTTON_RIGHT and not selected_units.is_empty():
		var target_prov = _get_province_under_mouse()
		if target_prov != null:
			var success_count = 0
			for u in selected_units:
				if u != null and is_instance_valid(u):
					if u.order_move_to(target_prov):
						success_count += 1
			if success_count > 0:
				print("Perintah gerak serentak (%d divisi): -> %s" % [success_count, target_prov.province_name])
			get_viewport().set_input_as_handled()
		else:
			# Klik kanan di luar provinsi membatalkan seleksi
			deselect_all_units()
	
	# Klik Kiri di area kosong membatalkan seleksi unit
	elif event.button_index == MOUSE_BUTTON_LEFT:
		var unit_under_mouse = _get_unit_under_mouse()
		var prov_under_mouse = _get_province_under_mouse()
		if unit_under_mouse == null and prov_under_mouse == null:
			deselect_all_units()

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
