# top_bar.gd
# Mengontrol tampilan visual HUD atas (Negara, Kas, Baja, Minyak, Manpower, dan Waktu).
extends PanelContainer

@export var player_country: Country
@export var economy_manager: Node

@onready var color_rect_flag: ColorRect = $MarginContainer/HBoxContainer/CountrySection/ColorRectFlag
@onready var label_country_name: Label = $MarginContainer/HBoxContainer/CountrySection/LabelCountryName

@onready var label_money: Label = $MarginContainer/HBoxContainer/ResourceSection/BoxMoney/LabelMoney
@onready var label_steel: Label = $MarginContainer/HBoxContainer/ResourceSection/BoxSteel/LabelSteel
@onready var label_fuel: Label = $MarginContainer/HBoxContainer/ResourceSection/BoxFuel/LabelFuel
@onready var label_manpower: Label = $MarginContainer/HBoxContainer/ResourceSection/BoxManpower/LabelManpower
@onready var label_arms: Label = $MarginContainer/HBoxContainer/ResourceSection/BoxArms/LabelArms
@onready var label_munitions: Label = $MarginContainer/HBoxContainer/ResourceSection/BoxMunitions/LabelMunitions

func _ready() -> void:
	if economy_manager != null and economy_manager.has_signal("economy_updated"):
		economy_manager.economy_updated.connect(_on_economy_updated)
	
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.daily_tick.connect(func(_d, _m, _y): _update_display())
	
	_update_display()

func _on_economy_updated(_country: Country) -> void:
	_update_display()

func _update_display() -> void:
	if player_country == null:
		return
	
	# Info Negara
	color_rect_flag.color = player_country.map_color
	label_country_name.text = player_country.country_name
	
	# Kas Negara
	var money_rate = player_country.daily_income_money
	label_money.text = "%s (%s%.0f)" % [
		_format_currency(player_country.money),
		"+" if money_rate >= 0 else "",
		money_rate
	]
	label_money.modulate = Color(0.3, 0.9, 0.4) if money_rate >= 0 else Color(0.9, 0.3, 0.3)
	
	# Baja
	var steel_rate = player_country.daily_income_steel
	label_steel.text = "%.0f (%s%.0f)" % [
		player_country.steel,
		"+" if steel_rate >= 0 else "",
		steel_rate
	]
	
	# Bahan Bakar
	var fuel_rate = player_country.daily_income_fuel
	label_fuel.text = "%.0f (%s%.0f)" % [
		player_country.fuel,
		"+" if fuel_rate >= 0 else "",
		fuel_rate
	]
	
	# Manpower
	var pop_rate = player_country.daily_manpower_growth
	label_manpower.text = "%s (%s%d)" % [
		_format_manpower(player_country.manpower),
		"+" if pop_rate >= 0 else "",
		pop_rate
	]
	
	# Persenjataan (Arms)
	var arms_rate = player_country.daily_income_arms
	label_arms.text = "%.0f (%s%.0f)" % [
		player_country.arms,
		"+" if arms_rate >= 0 else "",
		arms_rate
	]
	
	# Amunisi & Rudal (Munitions)
	var munit_rate = player_country.daily_income_munitions
	label_munitions.text = "%.0f (%s%.0f)" % [
		player_country.munitions,
		"+" if munit_rate >= 0 else "",
		munit_rate
	]

func _format_currency(val: float) -> String:
	if val >= 1000000.0:
		return "%.2fM" % (val / 1000000.0)
	elif val >= 1000.0:
		return "%.1fK" % (val / 1000.0)
	return "%.0f" % val

func _format_manpower(val: int) -> String:
	if val >= 1000000:
		return "%.1fM" % (float(val) / 1000000.0)
	elif val >= 1000:
		return "%.1fK" % (float(val) / 1000.0)
	return str(val)
