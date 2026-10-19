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

func _initialize_initial_units() -> void:
	if military_manager == null or world_map == null:
		return
	
	# Hubungkan military manager ke map manager
	military_manager.map_manager = world_map
	
	# Peta referensi provinsi
	var prov_batavia = world_map.get_node_or_null("Provinces/Prov_Batavia")
	var prov_jatim = world_map.get_node_or_null("Provinces/Prov_Jatim")
	var prov_laut_jawa = world_map.get_node_or_null("Provinces/Prov_Laut_Jawa")
	var prov_kalsel = world_map.get_node_or_null("Provinces/Prov_Kalsel")
	
	# 1. Divisi Infanteri Nusantara (Batavia)
	var unit_inf_batavia = military_manager.get_node_or_null("Units/Unit_Inf_Batavia")
	if unit_inf_batavia != null and prov_batavia != null:
		unit_inf_batavia.current_province = prov_batavia
		unit_inf_batavia.global_position = prov_batavia.get_center() + prov_batavia.position + Vector2(-30, 0)
	
	# 2. Skuadron Udara Jet Tempur Nusantara (Batavia)
	var unit_air = military_manager.get_node_or_null("Units/Unit_Fighter_Batavia")
	if unit_air != null and prov_batavia != null:
		unit_air.current_province = prov_batavia
		unit_air.global_position = prov_batavia.get_center() + prov_batavia.position + Vector2(30, -25)
	
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
