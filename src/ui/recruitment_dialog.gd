# recruitment_dialog.gd
# Dialog pemilihan divisi militer untuk dilatih/diproduksi di provinsi tertentu.
class_name RecruitmentDialog
extends PanelContainer

@export var player_country: Country
@export var production_manager: ProductionManager

@export var infantry_data: UnitData
@export var tank_data: UnitData
@export var frigate_data: UnitData
@export var fighter_data: UnitData

var target_province: Province = null

@onready var label_province_name: Label = $MarginContainer/VBox/Header/VBoxTitles/LabelProvinceName
@onready var btn_close: Button = $MarginContainer/VBox/Header/BtnClose
@onready var cards_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/CardsContainer

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(func(): visible = false)
	
	# Load default presets if not injected via Inspector
	if infantry_data == null:
		infantry_data = load("res://src/data/units/infantry_division.tres")
	if tank_data == null:
		tank_data = load("res://src/data/units/tank_division.tres")
	if frigate_data == null:
		frigate_data = load("res://src/data/units/frigate_fleet.tres")
	if fighter_data == null:
		fighter_data = load("res://src/data/units/fighter_wing.tres")

func open_for_province(prov: Province) -> void:
	if prov == null:
		visible = false
		return
	
	target_province = prov
	label_province_name.text = "Pangkalan: %s" % prov.province_name
	_rebuild_cards()
	visible = true

func _rebuild_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
	
	var unit_list = [infantry_data, tank_data, frigate_data, fighter_data]
	for data in unit_list:
		if data != null:
			_create_unit_card(data)

func _create_unit_card(data: UnitData) -> void:
	var card = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)
	
	# Icon Matra
	var icon_label = Label.new()
	match data.domain:
		UnitData.Domain.LAND:
			icon_label.text = "🚜" if data.hard_attack > 10 else "🪖"
		UnitData.Domain.SEA:
			icon_label.text = "🚢"
		UnitData.Domain.AIR:
			icon_label.text = "✈️"
	icon_label.add_theme_font_size_override("font_size", 22)
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_label)
	
	# Info Unit & Biaya
	var vbox_info = VBoxContainer.new()
	vbox_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var label_name = Label.new()
	label_name.text = data.unit_name
	label_name.add_theme_font_size_override("font_size", 13)
	vbox_info.add_child(label_name)
	
	var label_costs = Label.new()
	label_costs.text = "Biaya: $%d | 👥 %d | 🔫 %d | 🚀 %d | ⏱️ %d Hari" % [
		int(data.production_cost_money),
		data.required_manpower,
		int(data.production_cost_arms),
		int(data.production_cost_munitions),
		data.production_days
	]
	label_costs.add_theme_font_size_override("font_size", 10)
	label_costs.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	vbox_info.add_child(label_costs)
	
	hbox.add_child(vbox_info)
	
	# Tombol Rekrut
	var btn_recruit = Button.new()
	btn_recruit.text = "Rekrut"
	btn_recruit.custom_minimum_size = Vector2(70, 30)
	btn_recruit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Cek kelaikan rekrutmen
	var check = { "can": true, "reason": "" }
	if production_manager != null:
		check = production_manager.can_recruit(player_country, data, target_province)
	
	if check.can:
		btn_recruit.disabled = false
		btn_recruit.tooltip_text = "Mulai pelatihan divisi ini."
		btn_recruit.pressed.connect(func(): _on_recruit_clicked(data))
	else:
		btn_recruit.disabled = true
		btn_recruit.tooltip_text = check.reason
	
	hbox.add_child(btn_recruit)
	cards_container.add_child(card)

func _on_recruit_clicked(data: UnitData) -> void:
	if production_manager == null or player_country == null or target_province == null:
		return
	
	var order = production_manager.recruit_unit(player_country, data, target_province)
	if order != null:
		# Refresh tampilan untuk update status kelayakan sumber daya
		_rebuild_cards()
