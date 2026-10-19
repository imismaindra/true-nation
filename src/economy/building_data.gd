# building_data.gd
class_name BuildingData
extends Resource

enum BuildingType {
	FACTORY,       # Menghasilkan Baja & kapasitas produksi militer
	AIRBASE,       # Pangkalan jet & drone, memperluas jangkauan udara
	NAVAL_BASE,    # Pelabuhan bersandar & produksi kapal perang
	BARRACKS,      # Mempercepat rekrutmen infanteri
	BUNKER,        # Memberikan bonus pertahanan bagi garnisun
	RADAR_STATION  # Membuka kabut perang di provinsi tetangga
}

@export var building_type: BuildingType = BuildingType.FACTORY
@export var building_name: String = "Pabrik Industri"
@export var build_cost_money: float = 500.0
@export var build_cost_steel: float = 50.0
@export var build_days: int = 30

@export_group("Outputs & Bonuses")
@export var daily_money_bonus: float = 5.0
@export var daily_steel_bonus: float = 2.0
@export var defense_bonus_percent: float = 0.0
@export var max_level: int = 5
