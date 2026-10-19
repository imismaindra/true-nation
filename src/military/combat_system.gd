# combat_system.gd
# Mengelola simulasi pertempuran darat, laut, dan udara secara real-time per jam (Hourly Tick).
class_name CombatSystem
extends Node

class Battle:
	var province: Province
	var attackers: Array = []
	var defenders: Array = []
	var battle_marker: Node2D = null
	var is_active: bool = true

var active_battles: Array[Battle] = []

signal battle_started(battle: Battle)
signal battle_resolved(province: Province, winner_country: Country)

func _ready() -> void:
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.hourly_tick.connect(_on_hourly_tick)

func check_and_start_battle(prov: Province, potential_attacker: MilitaryUnit, military_manager: Node2D) -> void:
	if prov == null or potential_attacker == null or military_manager == null:
		return
	
	# Cari apakah sudah ada pertempuran aktif di provinsi ini
	for b in active_battles:
		if b.province == prov and b.is_active:
			if not b.attackers.has(potential_attacker) and not b.defenders.has(potential_attacker):
				b.attackers.append(potential_attacker)
				potential_attacker.is_in_combat = true
			return
	
	# Cari musuh yang ada di provinsi tersebut
	var defenders: Array = []
	for u in military_manager.units:
		if u.current_province == prov and u.owner_country != potential_attacker.owner_country and not u.is_moving:
			defenders.append(u)
	
	if defenders.is_empty():
		return # Tidak ada musuh, wilayah aman
	
	# Inisialisasi pertempuran baru
	var new_battle = Battle.new()
	new_battle.province = prov
	new_battle.attackers = [potential_attacker]
	new_battle.defenders = defenders
	
	potential_attacker.is_in_combat = true
	for d in defenders:
		d.is_in_combat = true
	
	_create_battle_marker(new_battle)
	active_battles.append(new_battle)
	battle_started.emit(new_battle)
	print("⚔️ PERTEMPURAN PECAH DI %s! Penyerang: %d unit vs Bertahan: %d unit" % [
		prov.province_name, new_battle.attackers.size(), new_battle.defenders.size()
	])

func _create_battle_marker(battle: Battle) -> void:
	var marker = Node2D.new()
	var label = Label.new()
	label.text = "⚔️"
	label.add_theme_font_size_override("font_size", 20)
	label.position = Vector2(-12, -40)
	marker.add_child(label)
	marker.position = battle.province.get_center() + battle.province.position
	battle.province.add_child(marker)
	battle.battle_marker = marker

func _on_hourly_tick(_hour: int, _day: int, _month: int, _year: int) -> void:
	for i in range(active_battles.size() - 1, -1, -1):
		var battle = active_battles[i]
		if not battle.is_active:
			continue
		
		_resolve_hourly_combat_round(battle)
		
		# Cek apakah pertempuran telah selesai
		if _check_battle_ended(battle):
			_end_battle(battle)
			active_battles.remove_at(i)

func _resolve_hourly_combat_round(battle: Battle) -> void:
	if battle.province == null:
		return
	
	# 1. Konsumsi Amunisi Pihak Penyerang
	var atk_country: Country = null
	if not battle.attackers.is_empty():
		atk_country = battle.attackers[0].owner_country
	
	var atk_supply_outage = false
	if atk_country != null:
		var total_ammo_needed: float = 0.0
		for atk in battle.attackers:
			total_ammo_needed += _get_unit_ammo_consumption(atk)
		
		if atk_country.munitions >= total_ammo_needed:
			atk_country.munitions -= total_ammo_needed
		else:
			atk_country.munitions = 0.0
			atk_supply_outage = true
			print("🚨 KRISIS AMUNISI! Pasukan penyerang (%s) kehabisan amunisi di %s!" % [
				atk_country.country_name, battle.province.province_name
			])
	
	# 2. Konsumsi Amunisi Pihak Bertahan
	var def_country: Country = null
	if not battle.defenders.is_empty():
		def_country = battle.defenders[0].owner_country
	
	var def_supply_outage = false
	if def_country != null:
		var total_ammo_needed: float = 0.0
		for def in battle.defenders:
			total_ammo_needed += _get_unit_ammo_consumption(def)
		
		if def_country.munitions >= total_ammo_needed:
			def_country.munitions -= total_ammo_needed
		else:
			def_country.munitions = 0.0
			def_supply_outage = true
			print("🚨 KRISIS AMUNISI! Garnisun bertahan (%s) kehabisan amunisi di %s!" % [
				def_country.country_name, battle.province.province_name
			])
	
	# Sinkronisasi status krisis amunisi ke unit
	for atk in battle.attackers:
		if atk != null and is_instance_valid(atk):
			atk.has_supply_outage = atk_supply_outage
	for def in battle.defenders:
		if def != null and is_instance_valid(def):
			def.has_supply_outage = def_supply_outage
	
	# 3. Hitung total serangan pihak penyerang (kombinasi soft & hard attack)
	var total_atk_soft: float = 0.0
	var total_atk_hard: float = 0.0
	for atk in battle.attackers:
		if atk != null and atk.unit_data != null and atk.current_organization > 0:
			total_atk_soft += atk.unit_data.soft_attack
			total_atk_hard += atk.unit_data.hard_attack
	
	var total_atk_power = (total_atk_soft * 0.7) + (total_atk_hard * 0.3)
	if atk_supply_outage:
		total_atk_power *= 0.5 # Penalti daya serang -50% saat amunisi habis
	
	# 4. Hitung total serangan pihak bertahan
	var total_def_soft: float = 0.0
	var total_def_hard: float = 0.0
	for def in battle.defenders:
		if def != null and def.unit_data != null and def.current_organization > 0:
			total_def_soft += def.unit_data.soft_attack
			total_def_hard += def.unit_data.hard_attack
	
	var total_def_power = (total_def_soft * 0.7) + (total_def_hard * 0.3)
	if def_supply_outage:
		total_def_power *= 0.5 # Penalti daya serang -50% saat amunisi habis
	
	# 5. Bonus Benteng Pertahanan (Fortification) bagi Pihak Bertahan
	var defense_bonus = battle.province.get_defense_bonus() # e.g. 0.35 (+35%)
	
	# Efek Artileri Medan / MLRS: Pemboman saturasi mereduksi perlindungan benteng lawan hingga 60%
	var has_artillery = false
	for atk in battle.attackers:
		if atk != null and atk.unit_data != null and atk.current_organization > 0:
			if atk.unit_data.unit_type in [UnitData.UnitType.ARTILLERY_SP, UnitData.UnitType.MLRS]:
				has_artillery = true
				break
	if has_artillery and defense_bonus > 0.0:
		defense_bonus *= 0.4
	
	var fort_reduction = clampf(defense_bonus, 0.0, 0.7) # Reduksi damage hingga maksimal 70%
	
	# 6. Berikan damage ke pihak bertahan
	var dmg_to_defenders = (total_atk_power * 0.25) / float(max(1, battle.defenders.size()))
	dmg_to_defenders *= (1.0 - fort_reduction)
	
	var def_org_mult = 1.5 if def_supply_outage else 1.0 # Moral lebih cepat runtuh tanpa bekal peluru
	for def in battle.defenders:
		if def != null and is_instance_valid(def):
			def.take_damage(dmg_to_defenders * 0.2, dmg_to_defenders * def_org_mult)
	
	# 7. Berikan damage ke pihak penyerang
	var dmg_to_attackers = (total_def_power * 0.25) / float(max(1, battle.attackers.size()))
	var atk_org_mult = 1.5 if atk_supply_outage else 1.0
	for atk in battle.attackers:
		if atk != null and is_instance_valid(atk):
			atk.take_damage(dmg_to_attackers * 0.2, dmg_to_attackers * atk_org_mult)

func _get_unit_ammo_consumption(unit: MilitaryUnit) -> float:
	if unit == null or unit.unit_data == null:
		return 1.5
	match unit.unit_data.domain:
		UnitData.Domain.LAND:
			return 4.0 if unit.unit_data.hard_attack > 10 else 1.5
		UnitData.Domain.SEA:
			return 6.0
		UnitData.Domain.AIR:
			return 8.0
	return 1.5

func _check_battle_ended(battle: Battle) -> bool:
	# Bersihkan unit yang hancur / mundur
	battle.attackers = battle.attackers.filter(func(u): return u != null and is_instance_valid(u) and u.current_organization > 0)
	battle.defenders = battle.defenders.filter(func(u): return u != null and is_instance_valid(u) and u.current_organization > 0)
	
	return battle.attackers.is_empty() or battle.defenders.is_empty()

func _end_battle(battle: Battle) -> void:
	battle.is_active = false
	if battle.battle_marker != null and is_instance_valid(battle.battle_marker):
		battle.battle_marker.queue_free()
	
	var winner_country: Country = null
	if not battle.attackers.is_empty():
		winner_country = battle.attackers[0].owner_country
		print("🏆 PENYERANG MENANG DI %s!" % battle.province.province_name)
		# Penyerang merebut wilayah
		battle.province.owner_country = winner_country
		battle.province.update_visuals()
	elif not battle.defenders.is_empty():
		winner_country = battle.defenders[0].owner_country
		print("🛡️ BERTAHAN SUKSES DI %s!" % battle.province.province_name)
	
	# Reset status tempur unit
	for u in battle.attackers + battle.defenders:
		if u != null and is_instance_valid(u):
			u.is_in_combat = false
	
	battle_resolved.emit(battle.province, winner_country)
