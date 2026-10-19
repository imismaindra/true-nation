# fog_of_war_manager.gd
# Mengelola sistem kabut perang (Fog of War) 2D, jangkauan sensor radar/jet, dan intelijen tempur.
class_name FogOfWarManager
extends Node

@export var map_manager: MapManager
@export var military_manager: MilitaryManager
@export var player_country: Country

var explored_province_ids: Dictionary = {}

signal fog_updated()

func _ready() -> void:
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.unit_movement_started.connect(func(_u, _f, _t): update_fog_of_war())
		event_bus.unit_movement_finished.connect(func(_u, _p): update_fog_of_war())
		event_bus.province_owner_changed.connect(func(_p, _o, _n): update_fog_of_war())
	
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.hourly_tick.connect(func(_h, _d, _m, _y): update_fog_of_war())
	
	# Panggilan update awal pada frame berikutnya setelah node scene selesai diinisialisasi
	call_deferred("update_fog_of_war")

func update_fog_of_war() -> void:
	if map_manager == null or player_country == null:
		return
	
	var visible_provinces: Array[Province] = []
	
	# 1. Wilayah Teritorial Sendiri & Sensor Fasilitas Pangkalan
	for prov in map_manager.provinces:
		if prov.owner_country == player_country:
			if not visible_provinces.has(prov):
				visible_provinces.append(prov)
			
			# Fasilitas Pangkalan Udara / Benteng memberikan radar garis pandang perbatasan
			if prov.has_airbase() or prov.get_defense_bonus() > 0.0:
				for neighbor in prov.connected_provinces:
					if not visible_provinces.has(neighbor):
						visible_provinces.append(neighbor)
	
	# 2. Sensor Pasukan / Unit Pemain
	if military_manager != null:
		for unit in military_manager.units:
			if unit != null and is_instance_valid(unit) and unit.owner_country == player_country:
				if unit.current_province != null and not visible_provinces.has(unit.current_province):
					visible_provinces.append(unit.current_province)
				if unit.target_province != null and not visible_provinces.has(unit.target_province):
					visible_provinces.append(unit.target_province)
				
				# Jet Tempur / Drone Intai memiliki jangkauan pengintaian udara (Air Reconnaissance)
				if unit.unit_data != null and unit.unit_data.domain == UnitData.Domain.AIR:
					var base_prov = unit.current_province
					if base_prov != null:
						for neighbor in base_prov.connected_provinces:
							if not visible_provinces.has(neighbor):
								visible_provinces.append(neighbor)
							# Drone UAV: Sensor pengintai 2-hop radius luas
							if unit.unit_data.unit_type == UnitData.UnitType.DRONE_UAV:
								for n2 in neighbor.connected_provinces:
									if not visible_provinces.has(n2):
										visible_provinces.append(n2)
	
	# 3. Terapkan Status Visibilitas ke Setiap Provinsi
	for prov in map_manager.provinces:
		if visible_provinces.has(prov):
			prov.set_visibility_state(Province.VisibilityState.VISIBLE)
			explored_province_ids[prov.province_id] = true
		elif explored_province_ids.has(prov.province_id):
			prov.set_visibility_state(Province.VisibilityState.FOGGED)
		else:
			prov.set_visibility_state(Province.VisibilityState.UNKNOWN)
	
	# 4. Sembunyikan / Munculkan Unit Musuh Sesuai Garis Pandang Sensor
	if military_manager != null:
		for unit in military_manager.units:
			if unit != null and is_instance_valid(unit):
				if unit.owner_country != player_country:
					var in_sight = false
					var is_sub = (unit.unit_data != null and unit.unit_data.unit_type == UnitData.UnitType.SUBMARINE)
					
					if is_sub:
						# Kapal selam musuh berkemampuan siluman bawah air: hanya terdeteksi jika ada armada kawan di provinsi yang sama
						if unit.current_province != null and visible_provinces.has(unit.current_province):
							for friendly in military_manager.units:
								if friendly.owner_country == player_country and friendly.current_province == unit.current_province:
									in_sight = true
									break
					else:
						if unit.current_province != null and visible_provinces.has(unit.current_province):
							in_sight = true
						elif unit.target_province != null and visible_provinces.has(unit.target_province):
							in_sight = true
					
					unit.visible = in_sight
					# Jika unit musuh tersembunyi, pastikan pemain tidak bisa memilihnya
					if not in_sight and unit.is_selected:
						military_manager.deselect_current_unit()
				else:
					unit.visible = true
	
	fog_updated.emit()
