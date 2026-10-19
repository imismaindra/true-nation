# notification_banner.gd
# Menampilkan banner notifikasi pop-up dinamis untuk peristiwa strategis penting di medan perang.
class_name NotificationBanner
extends PanelContainer

@export var player_country: Country
@export var production_manager: ProductionManager
@export var building_manager: Node

@onready var label_icon: Label = $Margin/HBox/LabelIcon
@onready var label_text: Label = $Margin/HBox/LabelText

var _hide_timer: float = 0.0

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

func show_notification(icon: String, text: String, color: Color = Color(1, 1, 1), duration: float = 4.0) -> void:
	label_icon.text = icon
	label_text.text = text
	label_text.modulate = color
	visible = true
	_hide_timer = duration

func _on_province_owner_changed(prov: Province, old_owner: Country, new_owner: Country) -> void:
	if prov == null or new_owner == null:
		return
	if new_owner == player_country:
		show_notification("🏆", "WILAYAH DIREBUT: %s kini berada di bawah kendali kita!" % prov.province_name, Color(0.4, 0.95, 0.5), 4.5)
	elif old_owner == player_country:
		show_notification("🚨", "WILAYAH JATUH: %s telah direbut oleh musuh!" % prov.province_name, Color(0.95, 0.35, 0.35), 4.5)

func _on_combat_started(prov: Province, _attackers: Array, _defenders: Array) -> void:
	if prov != null:
		show_notification("⚔️", "KONTAK TEMPUR: Pertempuran pecah di %s!" % prov.province_name, Color(1.0, 0.75, 0.3), 3.5)

func _on_production_completed(order: ProductionManager.ProductionOrder, _unit) -> void:
	if order != null and order.country == player_country:
		var u_name = order.unit_data.unit_name if order.unit_data else "Divisi"
		var p_name = order.target_province.province_name if order.target_province else "Pangkalan"
		show_notification("🎖️", "DIVISI BARU DEPLOY: %s telah selesai dirakit di %s!" % [u_name, p_name], Color(0.3, 0.85, 1.0), 4.0)

func _on_construction_completed(order) -> void:
	if order != null and order.country == player_country:
		var b_name = order.building_data.building_name if order.building_data else "Fasilitas"
		var p_name = order.target_province.province_name if order.target_province else "Wilayah"
		show_notification("🏗️", "FASILITAS SELESAI: %s telah aktif beroperasi di %s!" % [b_name, p_name], Color(0.95, 0.85, 0.4), 4.0)
