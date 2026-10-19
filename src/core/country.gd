# country.gd
class_name Country
extends Resource

@export var id: String = "IDN"
@export var country_name: String = "Indonesia"
@export var flag_icon: Texture2D
@export var map_color: Color = Color(0.2, 0.4, 0.8, 1.0)
@export var is_player: bool = false

# Pilar Ekonomi & Cadangan Nasional
@export_group("Resources")
@export var money: float = 10000.0
@export var steel: float = 500.0
@export var fuel: float = 1000.0
@export var manpower: int = 50000
@export var arms: float = 600.0         # Stok Persenjataan Militer
@export var munitions: float = 400.0    # Stok Amunisi & Rudal

# Pendapatan & Pengeluaran Harian
var daily_income_money: float = 0.0
var daily_income_steel: float = 0.0
var daily_income_fuel: float = 0.0
var daily_manpower_growth: int = 0
var daily_income_arms: float = 0.0
var daily_income_munitions: float = 0.0
