# unit_panel.gd
# Menampilkan detail divisi militer yang sedang dipilih pemain dan kontrol operasi tempur.
class_name UnitPanel
extends PanelContainer

@export var military_manager: Node

@onready var icon_symbol: TextureRect = $MarginContainer/VBoxContainer/Header/IconSymbol
@onready var label_title: Label = $MarginContainer/VBoxContainer/Header/VBox/LabelTitle
@onready var label_type: Label = $MarginContainer/VBoxContainer/Header/VBox/LabelType
@onready var color_rect_flag: ColorRect = $MarginContainer/VBoxContainer/InfoSection/HBoxOwner/ColorRectFlag
@onready var label_owner: Label = $MarginContainer/VBoxContainer/InfoSection/HBoxOwner/LabelOwnerValue
@onready var label_status: Label = $MarginContainer/VBoxContainer/StatusSection/LabelStatus
@onready var bar_strength: ProgressBar = $MarginContainer/VBoxContainer/CombatBars/BarStrength
@onready var bar_organization: ProgressBar = $MarginContainer/VBoxContainer/CombatBars/BarOrg
@onready var label_soft_attack: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelSoftVal
@onready var label_hard_attack: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelHardVal
@onready var label_defense: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelDefVal
@onready var label_speed: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelSpeedVal
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose
@onready var btn_halt: Button = $MarginContainer/VBoxContainer/ActionButtons/BtnHalt
@onready var btn_retreat: Button = $MarginContainer/VBoxContainer/ActionButtons/BtnRetreat

var current_unit: MilitaryUnit = null

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(_on_close_pressed)
	btn_halt.pressed.connect(_on_halt_pressed)
	btn_retreat.pressed.connect(_on_retreat_pressed)
	
	if military_manager != null and military_manager.has_signal("unit_selection_changed"):
		military_manager.unit_selection_changed.connect(_on_unit_selection_changed)

func _process(_delta: float) -> void:
	if visible and current_unit != null:
		_update_movement_status()

func _on_unit_selection_changed(unit: MilitaryUnit) -> void:
	if unit == null:
		visible = false
		current_unit = null
		return
	
	current_unit = unit
	_update_static_info()
	visible = true

func _update_static_info() -> void:
	if current_unit == null or current_unit.unit_data == null:
		return
	
	var data = current_unit.unit_data
	label_title.text = data.unit_name
	
	if icon_symbol != null:
		icon_symbol.texture = data.get_tactical_symbol_texture()
	
	match data.domain:
		UnitData.Domain.SEA:
			label_type.text = "Matra Laut | Operasional"
		UnitData.Domain.AIR:
			label_type.text = "Matra Udara | Operasional"
		_:
			label_type.text = "Matra Darat | Operasional"
	
	if current_unit.owner_country != null:
		color_rect_flag.color = current_unit.owner_country.map_color
		label_owner.text = current_unit.owner_country.country_name
	
	bar_strength.value = (current_unit.current_strength / data.max_strength) * 100.0
	bar_organization.value = (current_unit.current_organization / data.max_organization) * 100.0
	
	label_soft_attack.text = str(data.soft_attack)
	label_hard_attack.text = str(data.hard_attack)
	label_defense.text = str(data.defense)
	label_speed.text = "%.1f km/h" % (data.speed * 15.0)
	
	_update_button_states()

func _update_movement_status() -> void:
	if current_unit == null:
		return
	
	# Update bar moral dan strength secara live
	if current_unit.unit_data != null:
		bar_strength.value = (current_unit.current_strength / current_unit.unit_data.max_strength) * 100.0
		bar_organization.value = (current_unit.current_organization / current_unit.unit_data.max_organization) * 100.0
	
	if current_unit.is_in_combat:
		label_status.text = "[KONTAK TEMPUR] Terlibat pertempuran sengit!"
		label_status.modulate = Color(1.0, 0.25, 0.25)
	elif current_unit.is_moving and current_unit.target_province != null:
		var pct = int(current_unit.movement_progress * 100.0)
		label_status.text = "[GERAK] Menuju %s (%d%%)" % [current_unit.target_province.province_name, pct]
		label_status.modulate = Color(0.3, 0.85, 1.0)
	elif current_unit.current_province != null:
		label_status.text = "[SIAGA] Bertugas di %s" % current_unit.current_province.province_name
		label_status.modulate = Color(0.8, 0.9, 0.8)
	
	_update_button_states()

func _update_button_states() -> void:
	if current_unit == null:
		return
	btn_halt.disabled = not current_unit.is_moving or current_unit.is_in_combat
	btn_retreat.disabled = not current_unit.is_in_combat

func _on_halt_pressed() -> void:
	if current_unit != null and current_unit.has_method("halt_movement"):
		current_unit.halt_movement()

func _on_retreat_pressed() -> void:
	if current_unit != null and current_unit.has_method("retreat_from_combat"):
		current_unit.retreat_from_combat()

func _on_close_pressed() -> void:
	visible = false
	if military_manager != null and military_manager.has_method("deselect_current_unit"):
		military_manager.deselect_current_unit()
