# building_data.gd
# Mendefinisikan tipe dan atribut fasilitas strategis / pabrik di provinsi.
class_name BuildingData
extends Resource

enum BuildingType {
	ARMS_FACTORY,       # Pabrik Senjata Militer (+20 Arms/hari, -5 Baja, -$30)
	MUNITIONS_PLANT,    # Pabrik Amunisi & Rudal (+25 Munitions/hari, -2 Baja, -4 Minyak, -$40)
	STEEL_FOUNDRY,      # Industri Baja Tambang (+15 Baja/hari)
	OIL_REFINERY,       # Kilang Minyak Bumi (+10 Minyak/hari)
	NAVAL_DOCKYARD,     # Pangkalan Laut (Syarat armada kapal perang, +2% HP/hari)
	AIRBASE,            # Pangkalan Udara (Syarat jet tempur)
	FORTIFICATION       # Benteng Perbatasan (+35% Defense)
}

@export var building_id: String = "arms_factory"
@export var building_name: String = "Pabrik Senjata Militer"
@export var building_type: BuildingType = BuildingType.ARMS_FACTORY
@export var icon: String = "res://assets/sprites/ui/icon_building_factory.svg"
@export_multiline var description: String = ""

func get_icon_texture() -> Texture2D:
	if icon != "" and ResourceLoader.exists(icon):
		return load(icon)
	return load("res://assets/sprites/ui/icon_building_factory.svg")

@export_group("Construction Costs & Time")
@export var build_cost_money: float = 600.0
@export var build_cost_steel: float = 40.0
@export var build_cost_fuel: float = 0.0
@export var build_days: int = 12
@export var requires_coastal: bool = false

@export_group("Daily Upkeep & Inputs")
@export var daily_money_upkeep: float = 30.0
@export var daily_steel_input: float = 5.0
@export var daily_fuel_input: float = 0.0

@export_group("Daily Outputs & Bonuses")
@export var daily_arms_output: float = 20.0
@export var daily_munitions_output: float = 0.0
@export var daily_steel_output: float = 0.0
@export var daily_fuel_output: float = 0.0
@export var defense_bonus_percent: float = 0.0
