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
		if not time_mgr.daily_tick.is_connected(_on_daily_tick):
			time_mgr.daily_tick.connect(_on_daily_tick)
	
	# Kalkulasi awal
	recalculate_country_incomes()

func _on_daily_tick(_day: int, _month: int, _year: int) -> void:
	recalculate_all_countries_incomes()
	var countries = _get_active_countries()
	for c in countries:
		_apply_daily_income(c)
	
	if player_country != null:
		economy_updated.emit(player_country)

func recalculate_country_incomes() -> void:
	recalculate_all_countries_incomes()

func recalculate_all_countries_incomes() -> void:
	if map_manager == null:
		return
	
	var countries = _get_active_countries()
	for c in countries:
		_calculate_income_for(c)

func _get_active_countries() -> Array[Country]:
	var result: Array[Country] = []
	if map_manager == null:
		if player_country != null:
			result.append(player_country)
		return result
	
	for prov in map_manager.provinces:
		if prov.owner_country != null and not result.has(prov.owner_country):
			result.append(prov.owner_country)
	
	if player_country != null and not result.has(player_country):
		result.append(player_country)
	return result

func _calculate_income_for(c: Country) -> void:
	if c == null or map_manager == null:
		return
	
	var total_money: float = 0.0
	var total_steel: float = 0.0
	var total_fuel: float = 0.0
	var total_pop_growth: int = 0
	var total_arms: float = 0.0
	var total_munitions: float = 0.0
	
	# Hitung seluruh output dari provinsi yang dimiliki negara
	for prov in map_manager.provinces:
		if prov.owner_country == c and not prov.is_sea_zone():
			# Output dasar wilayah
			total_money += prov.base_money_output
			total_steel += prov.base_steel_output
			total_fuel += prov.base_fuel_output
			total_pop_growth += int(prov.population * 0.0001) # Pertumbuhan 0.01% per hari
			
			# Fasilitas / Pabrik militer & industri
			for bld in prov.buildings:
				if bld != null:
					# Biaya operasional harian & bahan baku
					total_money -= bld.daily_money_upkeep
					total_steel -= bld.daily_steel_input
					total_fuel -= bld.daily_fuel_input
					
					# Komoditas yang dihasilkan
					total_arms += bld.daily_arms_output
					total_munitions += bld.daily_munitions_output
					total_steel += bld.daily_steel_output
					total_fuel += bld.daily_fuel_output
	
	c.daily_income_money = total_money
	c.daily_income_steel = total_steel
	c.daily_income_fuel = total_fuel
	c.daily_manpower_growth = total_pop_growth
	c.daily_income_arms = total_arms
	c.daily_income_munitions = total_munitions

func _apply_daily_income(country: Country) -> void:
	if country == null:
		return
	
	country.money = maxf(0.0, country.money + country.daily_income_money)
	country.steel = maxf(0.0, country.steel + country.daily_income_steel)
	country.fuel = maxf(0.0, country.fuel + country.daily_income_fuel)
	country.manpower += country.daily_manpower_growth
	country.arms = maxf(0.0, country.arms + country.daily_income_arms)
	country.munitions = maxf(0.0, country.munitions + country.daily_income_munitions)
