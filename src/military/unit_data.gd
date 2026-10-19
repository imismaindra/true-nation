# unit_data.gd
class_name UnitData
extends Resource

enum Domain {
	LAND,
	SEA,
	AIR
}

enum UnitType {
	# Darat (Infanteri)
	RIFLEMAN,
	SNIPER,
	MEDIC,
	ENGINEER,
	AT_SPECIALIST,
	# Darat (Kendaraan Tempur)
	LIGHT_TANK,
	MEDIUM_TANK,
	MAIN_BATTLE_TANK,
	IFV,
	APC,
	ARTILLERY_SP,
	# Udara
	FIGHTER_JET,
	MULTIROLE_FIGHTER,
	ATTACK_AIRCRAFT,
	TRANSPORT_AIRCRAFT,
	HELICOPTER,
	DRONE_UAV,
	# Laut
	CORVETTE,
	FRIGATE,
	DESTROYER,
	LANDING_SHIP_DOCK,
	AIRCRAFT_CARRIER,
	SUBMARINE,
	# Darat Tambahan
	MLRS
}

@export var unit_type: UnitType = UnitType.RIFLEMAN
@export var unit_name: String = "Rifleman Division"
@export var domain: Domain = Domain.LAND
@export var icon_ui: Texture2D
@export var sprite_top_down: Texture2D
@export var sprite_side_profile: Texture2D

func get_tactical_symbol_texture() -> Texture2D:
	if icon_ui != null:
		return icon_ui
	var path = ""
	match domain:
		Domain.SEA:
			if unit_type == UnitType.SUBMARINE:
				path = "res://assets/sprites/ui/icon_unit_submarine.svg"
			else:
				path = "res://assets/sprites/ui/icon_unit_naval.svg"
		Domain.AIR:
			if unit_type == UnitType.HELICOPTER:
				path = "res://assets/sprites/ui/icon_unit_helicopter.svg"
			elif unit_type == UnitType.DRONE_UAV:
				path = "res://assets/sprites/ui/icon_unit_drone.svg"
			else:
				path = "res://assets/sprites/ui/icon_unit_air.svg"
		Domain.LAND:
			if unit_type in [UnitType.LIGHT_TANK, UnitType.MEDIUM_TANK, UnitType.MAIN_BATTLE_TANK, UnitType.IFV, UnitType.APC]:
				path = "res://assets/sprites/ui/icon_unit_tank.svg"
			elif unit_type in [UnitType.ARTILLERY_SP, UnitType.MLRS]:
				path = "res://assets/sprites/ui/icon_unit_artillery.svg"
			else:
				path = "res://assets/sprites/ui/icon_unit_infantry.svg"
	if path != "" and ResourceLoader.exists(path):
		return load(path)
	return load("res://assets/sprites/ui/icon_unit_infantry.svg")

@export_group("Combat Stats")
@export var max_strength: float = 100.0       # HP / Jumlah Personel
@export var max_organization: float = 100.0   # Moral / Disiplin Tempur
@export var soft_attack: float = 10.0         # Efektif vs Infanteri
@export var hard_attack: float = 2.0          # Efektif vs Tank / Armor
@export var air_attack: float = 0.0           # Anti-Air
@export var naval_attack: float = 0.0         # Serangan laut
@export var defense: float = 15.0             # Nilai bertahan
@export var speed: float = 1.0                # Kecepatan gerak antar provinsi

@export_group("Economic & Logistics")
@export var production_cost_money: float = 250.0
@export var production_cost_steel: float = 0.0
@export var production_cost_fuel: float = 0.0
@export var production_cost_arms: float = 120.0       # Biaya Persenjataan
@export var production_cost_munitions: float = 30.0   # Bekal Amunisi Awal
@export var production_days: int = 5                  # Waktu Pelatihan / Produksi (Hari)
@export var daily_fuel_consumption: float = 0.0
@export var daily_money_upkeep: float = 1.0
@export var required_manpower: int = 1000
