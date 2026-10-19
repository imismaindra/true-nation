# construction_dialog.gd
# Dialog pemilihan fasilitas strategis dan pabrik untuk dibangun di provinsi tertentu.
class_name ConstructionDialog
extends PanelContainer

@export var player_country: Country
@export var building_manager: Node

@export var arms_factory_data: BuildingData
@export var munitions_plant_data: BuildingData
@export var steel_foundry_data: BuildingData
@export var oil_refinery_data: BuildingData
@export var naval_dockyard_data: BuildingData
@export var airbase_data: BuildingData
@export var fortification_data: BuildingData

var target_province: Province = null

@onready var label_province_name: Label = $MarginContainer/VBox/Header/VBoxTitles/LabelProvinceName
@onready var label_slots: Label = $MarginContainer/VBox/Header/VBoxTitles/LabelSlots
@onready var btn_close: Button = $MarginContainer/VBox/Header/BtnClose
@onready var cards_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/CardsContainer

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(func(): visible = false)
	
	# Load default building presets if not assigned
	if arms_factory_data == null:
		arms_factory_data = load("res://src/data/buildings/arms_factory.tres")
	if munitions_plant_data == null:
		munitions_plant_data = load("res://src/data/buildings/munitions_plant.tres")
	if steel_foundry_data == null:
		steel_foundry_data = load("res://src/data/buildings/steel_foundry.tres")
	if oil_refinery_data == null:
		oil_refinery_data = load("res://src/data/buildings/oil_refinery.tres")
	if naval_dockyard_data == null:
		naval_dockyard_data = load("res://src/data/buildings/naval_dockyard.tres")
	if airbase_data == null:
		airbase_data = load("res://src/data/buildings/airbase.tres")
	if fortification_data == null:
		fortification_data = load("res://src/data/buildings/fortification.tres")

func open_for_province(prov: Province) -> void:
	if prov == null:
		visible = false
		return
	
	target_province = prov
	label_province_name.text = "Lokasi: %s (%s)" % [prov.province_name, prov.get_terrain_name()]
	label_slots.text = "Slot Fasilitas Terpakai: %d / %d" % [prov.buildings.size(), prov.max_building_slots]
	_rebuild_cards()
	visible = true

func _rebuild_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
	
	var list = [
		arms_factory_data,
		munitions_plant_data,
		steel_foundry_data,
		oil_refinery_data,
		naval_dockyard_data,
		airbase_data,
		fortification_data
	]
	
	for data in list:
		if data != null:
			_create_building_card(data)

func _create_building_card(data: BuildingData) -> void:
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
	
	# Icon Bangunan
	var icon_label = Label.new()
	icon_label.text = data.icon
	icon_label.add_theme_font_size_override("font_size", 22)
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_label)
	
	# Info Bangunan
	var vbox_info = VBoxContainer.new()
	vbox_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var label_name = Label.new()
	label_name.text = data.building_name
	label_name.add_theme_font_size_override("font_size", 13)
	vbox_info.add_child(label_name)
	
	var label_desc = Label.new()
	label_desc.text = data.description
	label_desc.add_theme_font_size_override("font_size", 10)
	label_desc.add_theme_color_override("font_color", Color(0.75, 0.8, 0.85))
	vbox_info.add_child(label_desc)
	
	var label_costs = Label.new()
	label_costs.text = "Biaya: $%d | ⚙️ %d Baja | 🛢️ %d Minyak | ⏱️ %d Hari" % [
		int(data.build_cost_money),
		int(data.build_cost_steel),
		int(data.build_cost_fuel),
		data.build_days
	]
	label_costs.add_theme_font_size_override("font_size", 10)
	label_costs.add_theme_color_override("font_color", Color(0.9, 0.75, 0.5))
	vbox_info.add_child(label_costs)
	
	hbox.add_child(vbox_info)
	
	# Tombol Bangun
	var btn_build = Button.new()
	btn_build.text = "Bangun"
	btn_build.custom_minimum_size = Vector2(70, 30)
	btn_build.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	var check = { "can": true, "reason": "" }
	if building_manager != null:
		check = building_manager.can_construct(player_country, data, target_province)
	
	if check.can:
		btn_build.disabled = false
		btn_build.tooltip_text = "Mulai pembangunan fasilitas ini."
		btn_build.pressed.connect(func(): _on_build_clicked(data))
	else:
		btn_build.disabled = true
		btn_build.tooltip_text = check.reason
	
	hbox.add_child(btn_build)
	cards_container.add_child(card)

func _on_build_clicked(data: BuildingData) -> void:
	if building_manager == null or player_country == null or target_province == null:
		return
	
	var order = building_manager.start_construction(player_country, data, target_province)
	if order != null:
		label_slots.text = "Slot Fasilitas Terpakai: %d / %d" % [target_province.buildings.size(), target_province.max_building_slots]
		_rebuild_cards()
