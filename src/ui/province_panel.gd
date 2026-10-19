# province_panel.gd
# Menampilkan detail data wilayah saat sebuah provinsi diklik di peta.
extends PanelContainer

@onready var label_title: Label = $MarginContainer/VBoxContainer/Header/VBox/LabelTitle
@onready var label_terrain: Label = $MarginContainer/VBoxContainer/Header/VBox/LabelTerrain
@onready var label_owner: Label = $MarginContainer/VBoxContainer/InfoSection/HBoxOwner/LabelOwnerValue
@onready var color_rect_flag: ColorRect = $MarginContainer/VBoxContainer/InfoSection/HBoxOwner/ColorRectFlag
@onready var label_money: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelMoneyValue
@onready var label_steel: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelSteelValue
@onready var label_fuel: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelFuelValue
@onready var label_population: Label = $MarginContainer/VBoxContainer/ResourceSection/Grid/LabelPopValue
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose

var current_province: Province = null

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(_on_close_pressed)
	
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

func _on_close_pressed() -> void:
	visible = false
	if current_province != null:
		current_province.set_selected(false)
		current_province = null

func _format_number(n: int) -> String:
	if n >= 1000000:
		return "%.1f Juta" % (float(n) / 1000000.0)
	elif n >= 1000:
		return "%d Ribu" % (n / 1000)
	return str(n)
