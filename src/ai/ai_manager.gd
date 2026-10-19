# ai_manager.gd
# Mengontrol kecerdasan buatan faksi lawan (Rival / Krasnovian Federation).
# Mengimplementasikan Finite-State Machine (FSM): Evaluasi, Rekrutmen, Ekspansi, Invasi, dan Garnisun.
class_name AIManager
extends Node

@export var rival_country: Country
@export var player_country: Country
@export var map_manager: MapManager
@export var military_manager: MilitaryManager
@export var production_manager: ProductionManager
@export var building_manager: Node

@export var infantry_data: UnitData
@export var tank_data: UnitData

signal ai_decision_executed(decision_type: String, details: String)

func _ready() -> void:
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		if not time_mgr.daily_tick.is_connected(_on_daily_tick):
			time_mgr.daily_tick.connect(_on_daily_tick)
	
	if infantry_data == null:
		infantry_data = load("res://src/data/units/infantry_division.tres")
	if tank_data == null:
		tank_data = load("res://src/data/units/tank_division.tres")

func _on_daily_tick(_day: int, _month: int, _year: int) -> void:
	execute_ai_turn()

func execute_ai_turn() -> void:
	if rival_country == null or map_manager == null or military_manager == null:
		return
	
	# 1. Mode Evaluasi (Assessment)
	var rival_units = _get_units_for_country(rival_country)
	var idle_units = rival_units.filter(func(u): return not u.is_moving and not u.is_in_combat and u.current_organization > 25.0)
	var rival_provinces = _get_provinces_for_country(rival_country)
	
	if rival_provinces.is_empty():
		return # Faksi telah kehilangan seluruh teritorial
	
	# 2. Mode Rekrutmen & Produksi Mandiri
	if rival_units.size() < 3 and production_manager != null:
		_try_recruit_division(rival_provinces)
	
	# 3. Mode Ekspansi ke Wilayah Netral yang Belum Dikawal
	if not idle_units.is_empty():
		var expansion_done = _try_expand_to_neutral(idle_units)
		if expansion_done:
			idle_units = idle_units.filter(func(u): return not u.is_moving and not u.is_in_combat)
	
	# 4. Mode Serangan Balas / Invasi (Offensive Counter-Attack)
	if rival_country.munitions >= 40.0 and not idle_units.is_empty():
		var attack_done = _try_offensive_strike(idle_units)
		if attack_done:
			idle_units = idle_units.filter(func(u): return not u.is_moving and not u.is_in_combat)
	
	# 5. Mode Bertahan (Garrison & Defense di Perbatasan)
	if not idle_units.is_empty():
		_try_garrison_borders(idle_units, rival_provinces)

func _try_recruit_division(rival_provinces: Array) -> void:
	if production_manager == null or rival_provinces.is_empty():
		return
	
	# Pilih provinsi darat teraman milik rival
	var target_prov: Province = null
	for prov in rival_provinces:
		if not prov.is_sea_zone():
			target_prov = prov
			break
	
	if target_prov == null:
		return
	
	# Prioritaskan Tank jika sumber daya mencukupi, jika tidak rekrut Infanteri
	var chosen_unit: UnitData = null
	if tank_data != null and production_manager.can_recruit(rival_country, tank_data, target_prov).can:
		chosen_unit = tank_data
	elif infantry_data != null and production_manager.can_recruit(rival_country, infantry_data, target_prov).can:
		chosen_unit = infantry_data
	
	if chosen_unit != null:
		var order = production_manager.recruit_unit(rival_country, chosen_unit, target_prov)
		if order != null:
			var msg = "Melatih %s di %s" % [chosen_unit.unit_name, target_prov.province_name]
			print("🤖 [AI RIVAL]: %s" % msg)
			ai_decision_executed.emit("RECRUIT", msg)

func _try_expand_to_neutral(idle_units: Array) -> bool:
	# Cari provinsi netral di peta
	var neutral_provinces: Array[Province] = []
	for prov in map_manager.provinces:
		if not prov.is_sea_zone() and (prov.owner_country == null or (prov.owner_country != rival_country and prov.owner_country != player_country)):
			neutral_provinces.append(prov)
	
	if neutral_provinces.is_empty():
		return false
	
	for unit in idle_units:
		if unit.current_province == null:
			continue
		
		# Cari provinsi netral terdekat
		for target_neutral in neutral_provinces:
			var next_hop = find_next_step(unit.current_province, target_neutral)
			if next_hop != null:
				var ok = unit.order_move_to(next_hop)
				if ok:
					var msg = "%s bergerak ekspansi menuju %s (via %s)" % [
						unit.unit_data.unit_name if unit.unit_data else "Divisi",
						target_neutral.province_name,
						next_hop.province_name
					]
					print("🤖 [AI RIVAL EKSPANSI]: %s" % msg)
					ai_decision_executed.emit("EXPANSION", msg)
					return true
	return false

func _try_offensive_strike(idle_units: Array) -> bool:
	if player_country == null:
		return false
	
	for unit in idle_units:
		if unit.current_province == null:
			continue
		
		# Cari provinsi pemain yang terhubung
		for neighbor in unit.current_province.connected_provinces:
			if neighbor.owner_country == player_country and not neighbor.is_sea_zone():
				# Serang langsung provinsi perbatasan pemain!
				var ok = unit.order_move_to(neighbor)
				if ok:
					var msg = "%s melancarkan serangan invasi ke %s!" % [
						unit.unit_data.unit_name if unit.unit_data else "Divisi",
						neighbor.province_name
					]
					print("🤖 [AI RIVAL SERANGAN]: %s" % msg)
					ai_decision_executed.emit("OFFENSIVE", msg)
					return true
			elif neighbor.is_sea_zone():
				# Evaluasi lompatan laut ke teritori pemain
				for sea_neighbor in neighbor.connected_provinces:
					if sea_neighbor.owner_country == player_country and not sea_neighbor.is_sea_zone():
						var ok = unit.order_move_to(neighbor)
						if ok:
							var msg = "%s bergerak melintasi %s menuju %s!" % [
								unit.unit_data.unit_name if unit.unit_data else "Divisi",
								neighbor.province_name,
								sea_neighbor.province_name
							]
							print("🤖 [AI RIVAL AMPHIBIOUS]: %s" % msg)
							ai_decision_executed.emit("AMPHIBIOUS_OFFENSIVE", msg)
							return true
	return false

func _try_garrison_borders(idle_units: Array, rival_provinces: Array) -> void:
	# Cari provinsi perbatasan yang belum memiliki garnisun
	var border_provinces: Array[Province] = []
	for prov in rival_provinces:
		if prov.is_sea_zone():
			continue
		for neighbor in prov.connected_provinces:
			if neighbor.owner_country != rival_country:
				if not border_provinces.has(prov):
					border_provinces.append(prov)
				break
	
	for border in border_provinces:
		# Hitung unit yang sudah ada di border ini
		var stationed_count = 0
		for u in military_manager.units:
			if u.owner_country == rival_country and (u.current_province == border or u.target_province == border):
				stationed_count += 1
		
		if stationed_count == 0 and not idle_units.is_empty():
			var unit_to_send = idle_units.pop_front()
			if unit_to_send.current_province != border:
				var next_step = find_next_step(unit_to_send.current_province, border)
				if next_step != null:
					unit_to_send.order_move_to(next_step)
					print("🤖 [AI RIVAL GARNISUN]: Menjaga perbatasan %s" % border.province_name)

func find_next_step(from_prov: Province, target_prov: Province) -> Province:
	if from_prov == null or target_prov == null or from_prov == target_prov:
		return null
	if from_prov.connected_provinces.has(target_prov):
		return target_prov
	
	# BFS mencari jalur terpendek melalui graf provinsi
	var queue: Array[Province] = [from_prov]
	var visited: Dictionary = { from_prov: null }
	
	while not queue.is_empty():
		var curr = queue.pop_front()
		if curr == target_prov:
			break
		for neighbor in curr.connected_provinces:
			if not visited.has(neighbor):
				visited[neighbor] = curr
				queue.append(neighbor)
	
	if not visited.has(target_prov):
		return null
	
	var curr_back = target_prov
	while visited[curr_back] != from_prov:
		curr_back = visited[curr_back]
		if curr_back == null:
			return null
	return curr_back

func _get_units_for_country(c: Country) -> Array[MilitaryUnit]:
	var result: Array[MilitaryUnit] = []
	if military_manager == null:
		return result
	for u in military_manager.units:
		if u != null and is_instance_valid(u) and u.owner_country == c:
			result.append(u)
	return result

func _get_provinces_for_country(c: Country) -> Array[Province]:
	var result: Array[Province] = []
	if map_manager == null:
		return result
	for p in map_manager.provinces:
		if p != null and p.owner_country == c:
			result.append(p)
	return result
