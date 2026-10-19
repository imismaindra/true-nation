# main.gd
# Scene utama mengintegrasikan Peta, Unit Militer, Ekonomi, Kamera, dan UI.
extends Node2D

@onready var world_map: Node2D = $WorldMap
@onready var military_manager: Node2D = $MilitaryManager
@onready var economy_manager: Node = $EconomyManager
@onready var combat_system: Node = $CombatSystem

func _ready() -> void:
	print("True Nation - Real-Time with Pause Engine Initialized.")
	_initialize_initial_units()

func _find_province(id: String) -> Province:
	if world_map == null:
		return null
	var provs = world_map.get_node_or_null("Provinces")
	if provs != null:
		for child in provs.get_children():
			if child is Province and child.province_id == id:
				return child
	return null

func _initialize_initial_units() -> void:
	if military_manager == null or world_map == null:
		return
	
	# Hubungkan military manager ke map manager
	military_manager.map_manager = world_map
	
	# Peta referensi provinsi
	var prov_batavia = _find_province("prov_batavia")
	var prov_jatim = _find_province("prov_jatim")
	var prov_laut_jawa = _find_province("sea_jawa")
	var prov_kalsel = _find_province("prov_kalsel")
	
	# 1. Divisi Infanteri Nusantara (Batavia)
	var unit_inf_batavia = military_manager.get_node_or_null("Units/Unit_Inf_Batavia")
	if unit_inf_batavia != null and prov_batavia != null:
		unit_inf_batavia.current_province = prov_batavia
		unit_inf_batavia.global_position = prov_batavia.get_center() + prov_batavia.position
	
	# 2. Skuadron Udara Jet Tempur Nusantara (Batavia)
	var unit_air = military_manager.get_node_or_null("Units/Unit_Fighter_Batavia")
	if unit_air != null and prov_batavia != null:
		unit_air.current_province = prov_batavia
		unit_air.global_position = prov_batavia.get_center() + prov_batavia.position
	
	# 3. Kavaleri Tank MBT Nusantara (Jawa Timur)
	var unit_tank_jatim = military_manager.get_node_or_null("Units/Unit_Tank_Jatim")
	if unit_tank_jatim != null and prov_jatim != null:
		unit_tank_jatim.current_province = prov_jatim
		unit_tank_jatim.global_position = prov_jatim.get_center() + prov_jatim.position
	
	# 4. Armada Laut Fregat Nusantara (Laut Jawa)
	var unit_navy = military_manager.get_node_or_null("Units/Unit_Frigate_LautJawa")
	if unit_navy != null and prov_laut_jawa != null:
		unit_navy.current_province = prov_laut_jawa
		unit_navy.global_position = prov_laut_jawa.get_center() + prov_laut_jawa.position
	
	# 5. Divisi Infanteri Koalisi Utara (Borneo Selatan - Musuh)
	var unit_inf_borneo = military_manager.get_node_or_null("Units/Unit_Inf_Borneo")
	if unit_inf_borneo != null and prov_kalsel != null:
		unit_inf_borneo.current_province = prov_kalsel
		unit_inf_borneo.global_position = prov_kalsel.get_center() + prov_kalsel.position
	
	military_manager.update_unit_formations()
	
	var fog_mgr = get_node_or_null("FogOfWarManager")
	if fog_mgr != null:
		fog_mgr.update_fog_of_war()
