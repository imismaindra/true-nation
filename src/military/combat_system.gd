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
	# 1. Hitung total serangan pihak penyerang (kombinasi soft & hard attack)
	var total_atk_soft: float = 0.0
	var total_atk_hard: float = 0.0
	for atk in battle.attackers:
		if atk != null and atk.unit_data != null and atk.current_organization > 0:
			total_atk_soft += atk.unit_data.soft_attack
			total_atk_hard += atk.unit_data.hard_attack
	
	# 2. Hitung total serangan pihak bertahan
	var total_def_soft: float = 0.0
	var total_def_hard: float = 0.0
	for def in battle.defenders:
		if def != null and def.unit_data != null and def.current_organization > 0:
			total_def_soft += def.unit_data.soft_attack
			total_def_hard += def.unit_data.hard_attack
	
	# 3. Berikan damage ke pihak bertahan (70% soft attack + 30% hard attack)
	var total_atk_power = (total_atk_soft * 0.7) + (total_atk_hard * 0.3)
	var dmg_to_defenders = (total_atk_power * 0.25) / float(max(1, battle.defenders.size()))
	for def in battle.defenders:
		if def != null:
			def.take_damage(dmg_to_defenders * 0.2, dmg_to_defenders)
	
	# 4. Berikan damage ke pihak penyerang (70% soft attack + 30% hard attack)
	var total_def_power = (total_def_soft * 0.7) + (total_def_hard * 0.3)
	var dmg_to_attackers = (total_def_power * 0.25) / float(max(1, battle.attackers.size()))
	for atk in battle.attackers:
		if atk != null:
			atk.take_damage(dmg_to_attackers * 0.2, dmg_to_attackers)

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
