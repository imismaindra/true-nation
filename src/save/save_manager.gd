# save_manager.gd
# Modul pengelola penyimpanan (Save) dan pemuatan (Load) status permainan berbasis JSON aman.
# Mendukung serialisasi waktu, ekonomi faksi, kepemilikan & fasilitas wilayah, dan unit militer.
extends Node

const SAVE_FILE_PATH: String = "user://savegame.json"

signal game_saved(success: bool, message: String)
signal game_loaded(success: bool, message: String)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	
	# Tombol Pintas F5 untuk Quick Save, F9 untuk Quick Load
	if event.keycode == KEY_F5:
		save_game()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F9:
		load_game()
		get_viewport().set_input_as_handled()

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func save_game(custom_path: String = SAVE_FILE_PATH) -> bool:
	var root = get_tree().root
	var main_node = root.find_child("Main", true, false)
	var time_mgr = get_node_or_null("/root/TimeManager")
	var map_mgr = root.find_child("WorldMap", true, false)
	var mil_mgr = root.find_child("MilitaryManager", true, false)
	var econ_mgr = root.find_child("EconomyManager", true, false)
	var banner = root.find_child("NotificationBanner", true, false)
	
	if main_node == null or time_mgr == null:
		var err_msg = "Gagal simpan: Sistem utama permainan belum terinisialisasi."
		print("❌ [SaveManager]: %s" % err_msg)
		game_saved.emit(false, err_msg)
		return false
	
	var save_dict: Dictionary = {
		"version": "0.2.1",
		"timestamp": Time.get_datetime_string_from_system(),
		"time": {
			"hour": time_mgr.hour,
			"day": time_mgr.day,
			"month": time_mgr.month,
			"year": time_mgr.year,
			"current_speed": time_mgr.current_speed,
			"is_paused": time_mgr.is_paused
		},
		"countries": {},
		"provinces": [],
		"units": []
	}
	
	# 1. Serialisasi Negara (Player & Rival)
	var player_c = main_node.get_node_or_null("EconomyManager")
	var player_country: Country = null
	if player_c != null and "player_country" in player_c:
		player_country = player_c.player_country
	
	var rival_node = main_node.get_node_or_null("AIManager")
	var rival_country: Country = null
	if rival_node != null and "rival_country" in rival_node:
		rival_country = rival_node.rival_country
	
	if player_country != null:
		save_dict.countries["player"] = _serialize_country(player_country)
	if rival_country != null:
		save_dict.countries["rival"] = _serialize_country(rival_country)
	
	# 2. Serialisasi Provinsi & Fasilitas Bangunan
	if map_mgr != null and "provinces" in map_mgr:
		for prov in map_mgr.provinces:
			if prov != null:
				var p_dict = {
					"id": prov.province_id,
					"name": prov.province_name,
					"owner": _get_country_key(prov.owner_country, player_country, rival_country),
					"buildings": []
				}
				for b in prov.buildings:
					if b != null and b.resource_path != "":
						p_dict.buildings.append(b.resource_path)
				save_dict.provinces.append(p_dict)
	
	# 3. Serialisasi Seluruh Divisi Militer
	if mil_mgr != null and "units" in mil_mgr:
		for u in mil_mgr.units:
			if u != null and is_instance_valid(u):
				var u_dict = {
					"unit_data_path": u.unit_data.resource_path if u.unit_data else "",
					"owner": _get_country_key(u.owner_country, player_country, rival_country),
					"pos_x": u.global_position.x,
					"pos_y": u.global_position.y,
					"current_province_id": u.current_province.province_id if u.current_province else "",
					"target_province_id": u.target_province.province_id if u.target_province else "",
					"is_moving": u.is_moving,
					"movement_progress": u.movement_progress,
					"current_strength": u.current_strength,
					"current_organization": u.current_organization
				}
				save_dict.units.append(u_dict)
	
	# Simpan ke File JSON
	var file = FileAccess.open(custom_path, FileAccess.WRITE)
	if file == null:
		var err = FileAccess.get_open_error()
		var msg = "Gagal menulis file penyimpanan (Error code: %d)." % err
		print("❌ [SaveManager]: %s" % msg)
		game_saved.emit(false, msg)
		return false
	
	var json_str = JSON.stringify(save_dict, "\t")
	file.store_string(json_str)
	file.close()
	
	var success_msg = "Permainan berhasil disimpan ke %s!" % custom_path
	print("💾 [SaveManager]: %s" % success_msg)
	game_saved.emit(true, success_msg)
	
	if banner != null and banner.has_method("show_notification"):
		banner.show_notification("💾", "PERMAINAN DISIMPAN: Progres strategis tersimpan aman!", Color(0.3, 0.9, 0.5), 3.5)
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_ui_click"):
		audio_mgr.play_ui_click()
	
	return true

func load_game(custom_path: String = SAVE_FILE_PATH) -> bool:
	var err_msg: String = ""
	if not FileAccess.file_exists(custom_path):
		err_msg = "File penyimpanan tidak ditemukan (%s)." % custom_path
		print("⚠️ [SaveManager]: %s" % err_msg)
		game_loaded.emit(false, err_msg)
		return false
	
	var file = FileAccess.open(custom_path, FileAccess.READ)
	if file == null:
		err_msg = "Gagal membaca berkas simpanan."
		print("❌ [SaveManager]: %s" % err_msg)
		game_loaded.emit(false, err_msg)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		err_msg = "Format file savegame korup atau tidak valid."
		print("❌ [SaveManager]: %s" % err_msg)
		game_loaded.emit(false, err_msg)
		return false
	
	var root = get_tree().root
	var main_node = root.find_child("Main", true, false)
	var time_mgr = get_node_or_null("/root/TimeManager")
	var map_mgr = root.find_child("WorldMap", true, false)
	var mil_mgr = root.find_child("MilitaryManager", true, false)
	var econ_mgr = root.find_child("EconomyManager", true, false)
	var banner = root.find_child("NotificationBanner", true, false)
	
	if main_node == null or time_mgr == null or map_mgr == null:
		err_msg = "Gagal memuat: Node peta atau sistem game belum siap."
		print("❌ [SaveManager]: %s" % err_msg)
		game_loaded.emit(false, err_msg)
		return false
	
	# Ambil referensi Country faksi
	var player_country: Country = null
	var rival_country: Country = null
	if econ_mgr != null and "player_country" in econ_mgr:
		player_country = econ_mgr.player_country
	var ai_mgr = root.find_child("AIManager", true, false)
	if ai_mgr != null and "rival_country" in ai_mgr:
		rival_country = ai_mgr.rival_country
	
	# 1. Pulihkan Waktu Permainan
	if "time" in parsed:
		var t = parsed.time
		time_mgr.hour = t.get("hour", 6)
		time_mgr.day = t.get("day", 1)
		time_mgr.month = t.get("month", 1)
		time_mgr.year = t.get("year", 2026)
		if t.get("is_paused", true):
			time_mgr.pause()
		else:
			time_mgr.set_speed(t.get("current_speed", 1))
	
	# 2. Pulihkan Data Ekonomi & Komoditas Negara
	if "countries" in parsed:
		if "player" in parsed.countries and player_country != null:
			_deserialize_country(player_country, parsed.countries.player)
		if "rival" in parsed.countries and rival_country != null:
			_deserialize_country(rival_country, parsed.countries.rival)
	
	# 3. Pulihkan Kepemilikan Provinsi & Fasilitas
	var prov_lookup = {}
	for prov in map_mgr.provinces:
		if prov != null:
			prov_lookup[prov.province_id] = prov
	
	if "provinces" in parsed:
		for p_data in parsed.provinces:
			var prov_id = p_data.get("id", "")
			if prov_lookup.has(prov_id):
				var prov: Province = prov_lookup[prov_id]
				# Set pemilik
				var prov_owner_key = p_data.get("owner", "")
				if prov_owner_key == "player":
					prov.owner_country = player_country
				elif prov_owner_key == "rival":
					prov.owner_country = rival_country
				else:
					prov.owner_country = null
				
				# Pulihkan bangunan
				prov.buildings.clear()
				var b_paths = p_data.get("buildings", [])
				for b_path in b_paths:
					if ResourceLoader.exists(b_path):
						var b_res = load(b_path)
						if b_res is BuildingData:
							prov.buildings.append(b_res)
				
				prov.update_visuals()
	
	# 4. Pulihkan Unit Militer
	if mil_mgr != null and "units" in parsed:
		# Bersihkan unit yang ada saat ini
		for old_u in mil_mgr.units:
			if old_u != null and is_instance_valid(old_u):
				old_u.queue_free()
		mil_mgr.units.clear()
		mil_mgr.selected_unit = null
		if "selected_units" in mil_mgr:
			mil_mgr.selected_units.clear()
		
		# Spawn ulang unit dari simpanan
		for u_data in parsed.units:
			var res_path = u_data.get("unit_data_path", "")
			if res_path != "" and ResourceLoader.exists(res_path):
				var u_res = load(res_path) as UnitData
				var unit_owner_key = u_data.get("owner", "player")
				var unit_owner = player_country if unit_owner_key == "player" else rival_country
				var unit_p_id = u_data.get("current_province_id", "")
				var current_p = prov_lookup.get(unit_p_id, null)
				
				if u_res != null and unit_owner != null and current_p != null:
					var new_unit = mil_mgr.spawn_unit(u_res, unit_owner, current_p)
					if new_unit != null:
						new_unit.global_position = Vector2(u_data.get("pos_x", current_p.position.x), u_data.get("pos_y", current_p.position.y))
						new_unit.current_strength = float(u_data.get("current_strength", 100.0))
						new_unit.current_organization = float(u_data.get("current_organization", 100.0))
						
						# Pulihkan pergerakan jika sedang bergerak
						if u_data.get("is_moving", false):
							var tgt_id = u_data.get("target_province_id", "")
							var target_p = prov_lookup.get(tgt_id, null)
							if target_p != null:
								new_unit.order_move_to(target_p)
								new_unit.movement_progress = float(u_data.get("movement_progress", 0.0))
	
	# 5. Sinkronisasi Ulang Sistem Kabut Perang & Ekonomi
	if econ_mgr != null and econ_mgr.has_method("recalculate_all_countries_incomes"):
		econ_mgr.recalculate_all_countries_incomes()
	
	var fog_mgr = root.find_child("FogOfWarManager", true, false)
	if fog_mgr != null and fog_mgr.has_method("update_fog_of_war"):
		fog_mgr.update_fog_of_war()
	
	var success_msg = "Permainan berhasil dimuat dari %s!" % custom_path
	print("📂 [SaveManager]: %s" % success_msg)
	game_loaded.emit(true, success_msg)
	
	if banner != null and banner.has_method("show_notification"):
		banner.show_notification("📂", "PERMAINAN DIMUAT: Situasi taktis berhasil dipulihkan!", Color(0.3, 0.85, 1.0), 3.5)
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_order_move"):
		audio_mgr.play_order_move()
	
	return true

# ----------------- HELPER SERIALISASI -----------------

func _serialize_country(c: Country) -> Dictionary:
	return {
		"money": c.money,
		"steel": c.steel,
		"fuel": c.fuel,
		"manpower": c.manpower,
		"arms": c.arms,
		"munitions": c.munitions,
		"daily_income_money": c.daily_income_money,
		"daily_income_steel": c.daily_income_steel,
		"daily_income_fuel": c.daily_income_fuel,
		"daily_manpower_growth": c.daily_manpower_growth,
		"daily_income_arms": c.daily_income_arms,
		"daily_income_munitions": c.daily_income_munitions
	}

func _deserialize_country(c: Country, data: Dictionary) -> void:
	c.money = float(data.get("money", c.money))
	c.steel = float(data.get("steel", c.steel))
	c.fuel = float(data.get("fuel", c.fuel))
	c.manpower = int(data.get("manpower", c.manpower))
	c.arms = float(data.get("arms", c.arms))
	c.munitions = float(data.get("munitions", c.munitions))
	c.daily_income_money = float(data.get("daily_income_money", 0.0))
	c.daily_income_steel = float(data.get("daily_income_steel", 0.0))
	c.daily_income_fuel = float(data.get("daily_income_fuel", 0.0))
	c.daily_manpower_growth = int(data.get("daily_manpower_growth", 0))
	c.daily_income_arms = float(data.get("daily_income_arms", 0.0))
	c.daily_income_munitions = float(data.get("daily_income_munitions", 0.0))

func _get_country_key(c: Country, player_c: Country, rival_c: Country) -> String:
	if c == player_c:
		return "player"
	elif c == rival_c:
		return "rival"
	return "neutral"
