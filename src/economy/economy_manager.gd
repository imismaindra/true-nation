# economy_manager.gd
# Mengelola kalkulasi pendapatan, pengeluaran, dan penambahan sumber daya harian (Daily Tick).
class_name EconomyManager
extends Node

@export var map_manager: MapManager
@export var player_country: Country

signal economy_updated(country: Country)

func _ready() -> void:
	# Hubungkan dengan detak harian TimeManager
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.daily_tick.connect(_on_daily_tick)
	
	# Kalkulasi awal
	recalculate_country_incomes()

func _on_daily_tick(_day: int, _month: int, _year: int) -> void:
	recalculate_country_incomes()
	_apply_daily_income(player_country)
	economy_updated.emit(player_country)

func recalculate_country_incomes() -> void:
	if map_manager == null or player_country == null:
		return
	
	var total_money: float = 0.0
	var total_steel: float = 0.0
	var total_fuel: float = 0.0
	var total_pop_growth: int = 0
	
	# Hitung seluruh output dari provinsi yang dimiliki negara pemain
	for prov in map_manager.provinces:
		if prov.owner_country == player_country and not prov.is_sea_zone():
			total_money += prov.base_money_output
			total_steel += prov.base_steel_output
			total_fuel += prov.base_fuel_output
			total_pop_growth += int(prov.population * 0.0001) # Pertumbuhan 0.01% per hari
	
	player_country.daily_income_money = total_money
	player_country.daily_income_steel = total_steel
	player_country.daily_income_fuel = total_fuel
	player_country.daily_manpower_growth = total_pop_growth

func _apply_daily_income(country: Country) -> void:
	if country == null:
		return
	
	country.money += country.daily_income_money
	country.steel += country.daily_income_steel
	country.fuel += country.daily_income_fuel
	country.manpower += country.daily_manpower_growth
