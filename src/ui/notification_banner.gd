# notification_banner.gd
# Menampilkan banner intelijen & situasi militer (SITREP Ticker) dinamis untuk peristiwa strategis di medan perang.
class_name NotificationBanner
extends PanelContainer

@export var player_country: Country
@export var production_manager: ProductionManager
@export var building_manager: Node

@onready var accent_bar: ColorRect = $AccentBar
@onready var icon_texture: TextureRect = $Margin/HBox/IconTexture
@onready var label_text: Label = $Margin/HBox/LabelText

var _hide_timer: float = 0.0

# Resource preloads
var _tex_victory = preload("res://assets/sprites/ui/icon_victory.svg")
var _tex_warning = preload("res://assets/sprites/ui/icon_warning.svg")
var _tex_battle = preload("res://assets/sprites/ui/icon_battle.svg")
var _tex_arms = preload("res://assets/sprites/ui/icon_arms.svg")
var _tex_building = preload("res://assets/sprites/ui/icon_building_factory.svg")
var _tex_save = preload("res://assets/sprites/ui/icon_save.svg")
var _tex_load = preload("res://assets/sprites/ui/icon_load.svg")

func _ready() -> void:
	visible = false
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.province_owner_changed.connect(_on_province_owner_changed)
		event_bus.combat_started.connect(_on_combat_started)
	
	if production_manager != null:
		production_manager.order_completed.connect(_on_production_completed)
	
	if building_manager != null:
		building_manager.construction_completed.connect(_on_construction_completed)

func _process(delta: float) -> void:
	if visible:
		_hide_timer -= delta
		if _hide_timer <= 0.0:
			visible = false

func show_sitrep(texture: Texture2D, text: String, accent_color: Color = Color("38bdf8"), duration: float = 4.0) -> void:
	if icon_texture != null and texture != null:
		icon_texture.texture = texture
	if accent_bar != null:
		accent_bar.color = accent_color
	if label_text != null:
		label_text.text = text
		label_text.modulate = accent_color
	visible = true
	_hide_timer = duration

# Kompatibilitas dengan panggilan lama (SaveManager, dsb)
func show_notification(icon_key: String, text: String, color: Color = Color(1, 1, 1), duration: float = 4.0) -> void:
	var tex = _tex_victory
	match icon_key:
		"save", "💾":
			tex = _tex_save
		"load", "📂":
			tex = _tex_load
		"battle", "⚔️":
			tex = _tex_battle
		"warning", "🚨":
			tex = _tex_warning
		"arms", "🎖️":
			tex = _tex_arms
		"building", "🏗️":
			tex = _tex_building
		_:
			tex = _tex_victory
	show_sitrep(tex, text, color, duration)

func _on_province_owner_changed(prov: Province, old_owner: Country, new_owner: Country) -> void:
	if prov == null or new_owner == null:
		return
	if new_owner == player_country:
		show_sitrep(_tex_victory, "KEDAULATAN PULIH: %s kini berada di bawah kendali kita!" % prov.province_name, Color(0.13, 0.77, 0.37), 4.5)
	elif old_owner == player_country:
		show_sitrep(_tex_warning, "PERINGATAN PERTAHANAN: %s telah direbut oleh faksi lawan!" % prov.province_name, Color(0.94, 0.27, 0.27), 4.5)

func _on_combat_started(prov: Province, _attackers: Array, _defenders: Array) -> void:
	if prov != null:
		show_sitrep(_tex_battle, "KONTAK TEMPUR AKTIF: Pertempuran sengit pecah di %s!" % prov.province_name, Color(0.96, 0.62, 0.04), 3.5)

func _on_production_completed(order: ProductionManager.ProductionOrder, _unit) -> void:
	if order != null and order.country == player_country:
		var u_name = order.unit_data.unit_name if order.unit_data else "Divisi"
		var p_name = order.target_province.province_name if order.target_province else "Pangkalan"
		show_sitrep(_tex_arms, "DIVISI TEMPUR SIAP: %s telah selesai dilatih di %s!" % [u_name, p_name], Color(0.22, 0.74, 0.97), 4.0)

func _on_construction_completed(order) -> void:
	if order != null and order.country == player_country:
		var b_name = order.building_data.building_name if order.building_data else "Fasilitas"
		var p_name = order.target_province.province_name if order.target_province else "Wilayah"
		show_sitrep(_tex_building, "FASILITAS OPERASIONAL: %s telah aktif di %s!" % [b_name, p_name], Color(0.22, 0.74, 0.97), 4.0)
