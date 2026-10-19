# unit.gd
# Node unit divisi militer di peta dengan sistem seleksi, domain (Darat, Laut, Udara), dan pertempuran.
class_name MilitaryUnit
extends Node2D

@export var unit_data: UnitData
@export var owner_country: Country
@export var current_province: Province

signal clicked(unit_node: Node2D)
signal movement_completed(unit_node: Node2D, arrived_province: Province)

# Status Tempur
var current_strength: float = 100.0
var current_organization: float = 100.0
var is_selected: bool = false
var is_in_combat: bool = false
var has_supply_outage: bool = false

# Pergerakan
var target_province: Province = null
var is_moving: bool = false
var movement_progress: float = 0.0 # 0.0 s.d. 1.0
var _start_position: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO

# Komponen Visual Internal
@onready var selection_ring: Line2D = $Visual/SelectionRing
@onready var bg_color_rect: ColorRect = $Visual/BadgeContainer/BgColor
@onready var flag_bar: ColorRect = $Visual/BadgeContainer/FlagBar
@onready var label_icon: Label = $Visual/BadgeContainer/HBox/LabelIcon
@onready var label_name: Label = $Visual/BadgeContainer/HBox/LabelName
@onready var bar_organization: ProgressBar = $Visual/BarOrganization
@onready var bar_movement: ProgressBar = $Visual/BarMovement
@onready var click_area: Area2D = $ClickArea

func _ready() -> void:
	if unit_data != null:
		current_strength = unit_data.max_strength
		current_organization = unit_data.max_organization
	
	# Hubungkan dengan detak per jam TimeManager
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.hourly_tick.connect(_on_hourly_tick)
	
	click_area.input_event.connect(_on_click_area_input)
	
	# Posisikan unit di tengah provinsi awal
	if current_province != null:
		global_position = current_province.get_center() + current_province.position
	
	_update_visuals()

func _process(delta: float) -> void:
	# Interpolasi posisi visual secara halus saat sedang bergerak
	if is_moving and target_province != null:
		var target_world_pos = _start_position.lerp(_target_position, movement_progress)
		global_position = global_position.lerp(target_world_pos, delta * 10.0)

func _on_hourly_tick(_hour: int, _day: int, _month: int, _year: int) -> void:
	# Pemulihan moral perlahan saat tidak bertempur dan tidak bergerak
	if not is_in_combat and not is_moving and current_organization < (unit_data.max_organization if unit_data else 100.0):
		current_organization = clampf(current_organization + 1.5, 0.0, unit_data.max_organization if unit_data else 100.0)
		bar_organization.value = current_organization
	
	if not is_moving or target_province == null:
		return
	
	# Kecepatan gerak dihitung per jam
	var speed_val = unit_data.speed if unit_data != null else 1.0
	var travel_step = (speed_val / 16.0)
	
	movement_progress = clampf(movement_progress + travel_step, 0.0, 1.0)
	bar_movement.value = movement_progress * 100.0
	
	if movement_progress >= 1.0:
		_arrive_at_target()

func order_move_to(new_province: Province) -> bool:
	if new_province == null or new_province == current_province:
		return false
	
	if is_in_combat:
		# Unit sedang terikat pertempuran, tidak bisa kabur tanpa perintah mundur
		return false
	
	# Validasi koneksi rute
	if current_province != null and not current_province.connected_provinces.has(new_province):
		return false
	
	# Aturan Domain Gerak Matra
	if unit_data != null:
		match unit_data.domain:
			UnitData.Domain.LAND:
				# Unit darat tidak bisa masuk zona laut langsung
				if new_province.is_sea_zone():
					return false
			UnitData.Domain.SEA:
				# Armada laut hanya bisa bergerak di zona laut
				if not new_province.is_sea_zone():
					return false
			UnitData.Domain.AIR:
				# Pesawat udara bebas melintasi darat dan laut
				pass
	
	target_province = new_province
	is_moving = true
	movement_progress = 0.0
	_start_position = global_position
	_target_position = new_province.get_center() + new_province.position
	
	bar_movement.visible = true
	bar_movement.value = 0.0
	return true

func _arrive_at_target() -> void:
	is_moving = false
	movement_progress = 0.0
	bar_movement.visible = false
	
	current_province = target_province
	target_province = null
	global_position = _target_position
	
	# Cek apakah ada sistem tempur yang aktif
	var combat_sys = get_tree().root.find_child("CombatSystem", true, false)
	var mil_mgr = get_tree().root.find_child("MilitaryManager", true, false)
	
	# Cek apakah terdapat unit musuh di provinsi ini
	var has_enemies = false
	if mil_mgr != null and current_province != null:
		for u in mil_mgr.units:
			if u != self and u.current_province == current_province and u.owner_country != owner_country and u.current_organization > 0:
				has_enemies = true
				break
	
	if has_enemies and combat_sys != null and mil_mgr != null:
		# Picu pertempuran! Wilayah belum bisa direbut sampai musuh kalah
		combat_sys.check_and_start_battle(current_province, self, mil_mgr)
	else:
		# Tidak ada musuh, wilayah langsung dikuasai jika daratan
		if current_province != null and owner_country != null:
			if current_province.owner_country != owner_country and not current_province.is_sea_zone():
				var old_owner = current_province.owner_country
				current_province.owner_country = owner_country
				current_province.update_visuals()
				var event_bus = get_node_or_null("/root/EventBus")
				if event_bus != null:
					event_bus.province_owner_changed.emit(current_province, old_owner, owner_country)
	
	movement_completed.emit(self, current_province)

func take_damage(strength_dmg: float, org_dmg: float) -> void:
	current_strength = maxf(0.0, current_strength - strength_dmg)
	current_organization = maxf(0.0, current_organization - org_dmg)
	bar_organization.value = current_organization
	
	if current_strength <= 0.0:
		# Unit musnah gugur dalam tugas
		print("💀 DIVISI %s HANCUR DALAM PERTEMPURAN!" % (unit_data.unit_name if unit_data else "Unit"))
		queue_free()
	elif current_organization <= 0.0:
		# Moral habis, divisi terpaksa mundur
		print("⚠️ DIVISI %s PUKUL MUNDUR!" % (unit_data.unit_name if unit_data else "Unit"))
		retreat()

func retreat() -> void:
	is_in_combat = false
	if current_province == null:
		return
	
	# Cari provinsi tetangga yang aman (milik sendiri atau sekutu)
	for neighbor in current_province.connected_provinces:
		if neighbor.owner_country == owner_country and not neighbor.is_sea_zone():
			target_province = neighbor
			is_moving = true
			movement_progress = 0.5 # Mundur lebih cepat
			_start_position = global_position
			_target_position = neighbor.get_center() + neighbor.position
			bar_movement.visible = true
			return

func set_selected(val: bool) -> void:
	is_selected = val
	selection_ring.visible = is_selected

func _update_visuals() -> void:
	if owner_country != null:
		flag_bar.color = owner_country.map_color
	
	if unit_data != null:
		label_name.text = unit_data.unit_name.substr(0, 12)
		match unit_data.domain:
			UnitData.Domain.SEA:
				label_icon.text = "🚢" # Armada Laut
			UnitData.Domain.AIR:
				label_icon.text = "✈️" # Skuadron Udara
			UnitData.Domain.LAND:
				if unit_data.unit_type in [UnitData.UnitType.LIGHT_TANK, UnitData.UnitType.MEDIUM_TANK, UnitData.UnitType.MAIN_BATTLE_TANK]:
					label_icon.text = "🚜" # Tank / Armor
				elif unit_data.unit_type == UnitData.UnitType.ARTILLERY_SP:
					label_icon.text = "💥" # Artileri
				else:
					label_icon.text = "🪖" # Infanteri
	
	bar_organization.value = current_organization
	selection_ring.visible = is_selected
	bar_movement.visible = is_moving

func _on_click_area_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		clicked.emit(self)
		get_viewport().set_input_as_handled()
