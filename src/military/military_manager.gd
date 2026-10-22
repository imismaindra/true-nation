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

var _right_drag_active: bool = false
var _right_drag_moved: bool = false
var _drag_start_screen: Vector2 = Vector2.ZERO
var _drag_start_world: Vector2 = Vector2.ZERO
var _drag_last_world: Vector2 = Vector2.ZERO

@onready var units_container: Node2D = $Units

func _ready() -> void:
	z_index = 50
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

func remove_unit(unit: MilitaryUnit) -> void:
	units.erase(unit)
	selected_units.erase(unit)
	if selected_unit == unit:
		selected_unit = null
		unit_selection_changed.emit(null)

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
			u_list[0].formation_offset = Vector2(0, -14)
		elif count == 2:
			u_list[0].formation_offset = Vector2(-44, -14)
			u_list[1].formation_offset = Vector2(44, -14)
		elif count == 3:
			u_list[0].formation_offset = Vector2(0, -38)
			u_list[1].formation_offset = Vector2(-44, 2)
			u_list[2].formation_offset = Vector2(44, 2)
		elif count == 4:
			u_list[0].formation_offset = Vector2(-44, -30)
			u_list[1].formation_offset = Vector2(44, -30)
			u_list[2].formation_offset = Vector2(-44, 6)
			u_list[3].formation_offset = Vector2(44, 6)
		else:
			var radius = 44.0 + (count * 4.0)
			for i in range(count):
				var angle = (float(i) / float(count)) * TAU
				u_list[i].formation_offset = Vector2(cos(angle), sin(angle)) * radius + Vector2(0, -8)


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

func select_all_units() -> int:
	var list: Array[MilitaryUnit] = []
	for u in units:
		if u != null and is_instance_valid(u) and u.owner_country == player_country:
			list.append(u)
	_select_unit_list(list)
	if not selected_units.is_empty():
		print("[CORPS] SELURUH PASUKAN: %d divisi dipilih" % selected_units.size())
	return selected_units.size()

func select_units_in_province(prov: Province) -> int:
	if prov == null or player_country == null:
		return 0
	
	var list: Array[MilitaryUnit] = []
	for u in units:
		if u != null and is_instance_valid(u) and u.owner_country == player_country:
			if u.current_province == prov:
				list.append(u)
	_select_unit_list(list)
	if not selected_units.is_empty():
		print("[CORPS] KORPS GABUNGAN: %d divisi dipilih di %s" % [selected_units.size(), prov.province_name])
	
	return selected_units.size()

func _select_unit_list(list: Array[MilitaryUnit]) -> void:
	deselect_all_units()
	for u in list:
		if u != null and is_instance_valid(u):
			u.set_selected(true)
			selected_units.append(u)
	if not selected_units.is_empty():
		selected_unit = selected_units[0]
		unit_selection_changed.emit(selected_unit)
		var event_bus = get_node_or_null("/root/EventBus")
		if event_bus != null:
			event_bus.unit_selected.emit(selected_unit)

func get_units_in_province(prov: Province, country: Country = null) -> Array[MilitaryUnit]:
	var result: Array[MilitaryUnit] = []
	for u in units:
		if u != null and is_instance_valid(u) and u.current_province == prov:
			if country == null or u.owner_country == country:
				result.append(u)
	return result

func find_path(from_prov: Province, to_prov: Province, domain: int) -> Array[Province]:
	var route: Array[Province] = []
	if from_prov == null or to_prov == null or from_prov == to_prov:
		return route
	if not _can_enter(to_prov, domain):
		return route
	
	var came_from: Dictionary = { from_prov: null }
	var queue: Array[Province] = [from_prov]
	while not queue.is_empty():
		var current = queue.pop_front()
		if current == to_prov:
			break
		for neighbor in current.connected_provinces:
			if neighbor == null or came_from.has(neighbor) or not _can_enter(neighbor, domain):
				continue
			came_from[neighbor] = current
			queue.append(neighbor)
	
	if not came_from.has(to_prov):
		return route
	
	var step = to_prov
	while step != from_prov:
		route.push_front(step)
		step = came_from[step]
	return route

func _can_enter(prov: Province, domain: int) -> bool:
	if domain == UnitData.Domain.SEA:
		return prov.is_sea_zone()
	return true

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
	# Ctrl+A: pilih seluruh divisi milik pemain di semua provinsi
	if event is InputEventKey and event.is_pressed() and not event.echo:
		if event.keycode == KEY_A and event.is_command_or_control_pressed():
			select_all_units()
			get_viewport().set_input_as_handled()
		return
	
	# Klik kanan + drag: seleksi kotak unit pemain
	if event is InputEventMouseMotion and _right_drag_active:
		if event.position.distance_to(_drag_start_screen) > 6.0:
			_right_drag_moved = true
		_drag_last_world = get_global_mouse_position()
		queue_redraw()
		return
	
	if not (event is InputEventMouseButton):
		return
	
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			_right_drag_active = true
			_right_drag_moved = false
			_drag_start_screen = event.position
			_drag_start_world = get_global_mouse_position()
			_drag_last_world = _drag_start_world
		elif _right_drag_active:
			_right_drag_active = false
			if _right_drag_moved:
				var drag_rect := Rect2(_drag_start_world, _drag_last_world - _drag_start_world).abs()
				_select_units_in_rect(drag_rect)
				queue_redraw()
			else:
				_issue_move_order()
			get_viewport().set_input_as_handled()
		return
	
	# Klik Kiri di area kosong membatalkan seleksi unit
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var unit_under_mouse = _get_unit_under_mouse()
		var prov_under_mouse = _get_province_under_mouse()
		if unit_under_mouse == null and prov_under_mouse == null:
			deselect_all_units()

func _draw() -> void:
	if not _right_drag_active or not _right_drag_moved:
		return
	var a := to_local(_drag_start_world)
	var b := to_local(_drag_last_world)
	var rect := Rect2(a, b - a).abs()
	draw_rect(rect, Color(0.25, 0.75, 1.0, 0.15), true)
	draw_rect(rect, Color(0.45, 0.9, 1.0, 0.9), false, 1.5)

func _select_units_in_rect(rect: Rect2) -> void:
	var list: Array[MilitaryUnit] = []
	for u in units:
		if u != null and is_instance_valid(u) and u.owner_country == player_country:
			if rect.has_point(u.global_position):
				list.append(u)
	_select_unit_list(list)
	if not selected_units.is_empty():
		print("[CORPS] SELEKSI KOTAK: %d divisi dipilih" % selected_units.size())

func _issue_move_order() -> void:
	if selected_units.is_empty():
		return
	var target_prov = _get_province_under_mouse()
	if target_prov == null:
		deselect_all_units()
		return
	
	var success_count = 0
	for u in selected_units:
		if u != null and is_instance_valid(u):
			var domain = u.unit_data.domain if u.unit_data != null else UnitData.Domain.LAND
			var route = find_path(u.current_province, target_prov, domain)
			if not route.is_empty() and u.follow_route(route):
				success_count += 1
	if success_count > 0:
		print("Perintah gerak serentak (%d divisi): -> %s" % [success_count, target_prov.province_name])


func _get_province_under_mouse() -> Province:
	if map_manager == null:
		return null
	var mouse_world_pos = get_global_mouse_position()
	for prov in map_manager.provinces:
		if prov.contains_point(mouse_world_pos - prov.position):
			return prov
	return null

func _get_unit_under_mouse() -> MilitaryUnit:
	var mouse_world_pos = get_global_mouse_position()
	for unit in units:
		if unit.global_position.distance_to(mouse_world_pos) <= 52.0:
			return unit
	return null
