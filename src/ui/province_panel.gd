# province_panel.gd
# Menampilkan detail data wilayah saat sebuah provinsi diklik di peta.
extends PanelContainer

@export var player_country: Country
@export var recruitment_dialog: RecruitmentDialog
@export var construction_dialog: PanelContainer

@onready var label_title: Label = $MarginContainer/VBoxContainer/Header/VBox/LabelTitle
@onready var label_terrain: Label = $MarginContainer/VBoxContainer/Header/VBox/LabelTerrain
@onready var label_owner: Label = $MarginContainer/VBoxContainer/InfoSection/HBoxOwner/LabelOwnerValue
@onready var color_rect_flag: ColorRect = $MarginContainer/VBoxContainer/InfoSection/HBoxOwner/ColorRectFlag
@onready var label_money: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelMoneyValue
@onready var label_steel: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelSteelValue
@onready var label_fuel: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelFuelValue
@onready var label_population: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelPopValue
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose
@onready var sep_action: HSeparator = $MarginContainer/VBoxContainer/HSeparator3
@onready var action_buttons: HBoxContainer = $MarginContainer/VBoxContainer/ActionButtons
@onready var btn_recruit: Button = $MarginContainer/VBoxContainer/ActionButtons/BtnRecruit
@onready var btn_build: Button = $MarginContainer/VBoxContainer/ActionButtons/BtnBuild
@onready var label_buildings_list: Label = $MarginContainer/VBoxContainer/BuildingSection/LabelBuildingsList

var current_province: Province = null

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(_on_close_pressed)
	btn_recruit.pressed.connect(_on_recruit_pressed)
	btn_build.pressed.connect(_on_build_pressed)
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.province_clicked.connect(_on_province_clicked)

func _on_province_clicked(province: Province) -> void:
	if province == null:
		visible = false
		current_province = null
		return
	
	current_province = province
	_update_ui()
	visible = true

func _update_ui() -> void:
	if current_province == null:
		return
	
	label_title.text = current_province.province_name
	label_terrain.text = current_province.get_terrain_name()
	
	# Informasi Kepemilikan Negara
	if current_province.is_sea_zone():
		label_owner.text = "Perairan Internasional"
		color_rect_flag.color = Color(0.2, 0.4, 0.7, 1.0)
	elif current_province.owner_country != null:
		label_owner.text = current_province.owner_country.country_name
		color_rect_flag.color = current_province.owner_country.map_color
	else:
		label_owner.text = "Wilayah Netral / Tanpa Pemilik"
		color_rect_flag.color = Color(0.5, 0.5, 0.5, 1.0)
	
	# Output Ekonomi
	label_money.text = "+%.1f / hari" % current_province.base_money_output
	label_steel.text = "+%.1f / hari" % current_province.base_steel_output
	label_fuel.text = "+%.1f / hari" % current_province.base_fuel_output
	label_population.text = "%s jiwa" % _format_number(current_province.population)
	
	# Fasilitas & Pabrik
	if current_province.buildings.is_empty():
		label_buildings_list.text = "Belum ada fasilitas dibangun."
	else:
		var b_texts: Array[String] = []
		for b in current_province.buildings:
			if b != null:
				b_texts.append("%s %s" % [b.icon, b.building_name])
		label_buildings_list.text = " • ".join(b_texts)
	
	# Opsi Aksi (Hanya aktif untuk wilayah darat milik pemain)
	var is_player_owned = (current_province.owner_country != null and current_province.owner_country == player_country and not current_province.is_sea_zone())
	action_buttons.visible = is_player_owned
	sep_action.visible = is_player_owned

func _on_recruit_pressed() -> void:
	if recruitment_dialog != null and current_province != null:
		recruitment_dialog.open_for_province(current_province)

func _on_build_pressed() -> void:
	if construction_dialog != null and current_province != null:
		construction_dialog.open_for_province(current_province)

func _on_close_pressed() -> void:
	visible = false
	if current_province != null:
		current_province.set_selected(false)
		current_province = null

func _format_number(n: int) -> String:
	if n >= 1000000:
		return "%.1f Juta" % (float(n) / 1000000.0)
	elif n >= 1000:
		return "%d Ribu" % int(float(n) / 1000.0)
	return str(n)
