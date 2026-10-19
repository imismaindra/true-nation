# recruitment_dialog.gd
# Dialog pemilihan divisi militer untuk dilatih/diproduksi di provinsi tertentu.
class_name RecruitmentDialog
extends PanelContainer

@export var player_country: Country
@export var production_manager: ProductionManager

@export var infantry_data: UnitData
@export var tank_data: UnitData
@export var artillery_data: UnitData
@export var helicopter_data: UnitData
@export var fighter_data: UnitData
@export var drone_data: UnitData
@export var frigate_data: UnitData
@export var submarine_data: UnitData

var target_province: Province = null

@onready var label_province_name: Label = $MarginContainer/VBox/Header/VBoxTitles/LabelProvinceName
@onready var btn_close: Button = $MarginContainer/VBox/Header/BtnClose
@onready var cards_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/CardsContainer

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(func(): visible = false)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()
	
	# Load default presets if not injected via Inspector
	if infantry_data == null:
		infantry_data = load("res://src/data/units/infantry_division.tres")
	if tank_data == null:
		tank_data = load("res://src/data/units/tank_division.tres")
	if artillery_data == null and ResourceLoader.exists("res://src/data/units/artillery_division.tres"):
		artillery_data = load("res://src/data/units/artillery_division.tres")
	if helicopter_data == null and ResourceLoader.exists("res://src/data/units/attack_helicopter_wing.tres"):
		helicopter_data = load("res://src/data/units/attack_helicopter_wing.tres")
	if fighter_data == null:
		fighter_data = load("res://src/data/units/fighter_wing.tres")
	if drone_data == null and ResourceLoader.exists("res://src/data/units/recon_drone_wing.tres"):
		drone_data = load("res://src/data/units/recon_drone_wing.tres")
	if frigate_data == null:
		frigate_data = load("res://src/data/units/frigate_fleet.tres")
	if submarine_data == null and ResourceLoader.exists("res://src/data/units/submarine_fleet.tres"):
		submarine_data = load("res://src/data/units/submarine_fleet.tres")

func open_for_province(prov: Province) -> void:
	if prov == null:
		visible = false
		return
	
	target_province = prov
	label_province_name.text = "Pangkalan: %s" % prov.province_name
	_rebuild_cards()
	visible = true

func _rebuild_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
	
	var unit_list = [
		infantry_data,
		tank_data,
		artillery_data,
		helicopter_data,
		fighter_data,
		drone_data,
		frigate_data,
		submarine_data
	]
	for data in unit_list:
		if data != null:
			_create_unit_card(data)

func _create_unit_card(data: UnitData) -> void:
	var card = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)
	
	# Icon Matra Taktis
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(32, 32)
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture = data.get_tactical_symbol_texture()
	hbox.add_child(icon_rect)
	
	# Info Unit & Biaya
	var vbox_info = VBoxContainer.new()
	vbox_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var label_name = Label.new()
	label_name.text = data.unit_name
	label_name.add_theme_font_size_override("font_size", 13)
	vbox_info.add_child(label_name)
	
	var label_costs = Label.new()
	label_costs.text = "Kas: $%d | Personel: %d | Senjata: %d | Amunisi: %d | Waktu: %d Hari" % [
		int(data.production_cost_money),
		data.required_manpower,
		int(data.production_cost_arms),
		int(data.production_cost_munitions),
		data.production_days
	]
	label_costs.add_theme_font_size_override("font_size", 10)
	label_costs.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95))
	vbox_info.add_child(label_costs)
	
	hbox.add_child(vbox_info)
	
	# Tombol Rekrut
	var btn_recruit = Button.new()
	btn_recruit.text = "Rekrut"
	btn_recruit.custom_minimum_size = Vector2(70, 30)
	btn_recruit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Cek kelaikan rekrutmen
	var check = { "can": true, "reason": "" }
	if production_manager != null:
		check = production_manager.can_recruit(player_country, data, target_province)
	
	if check.can:
		btn_recruit.disabled = false
		btn_recruit.tooltip_text = "Mulai pelatihan divisi ini."
		btn_recruit.pressed.connect(func(): _on_recruit_clicked(data))
	else:
		btn_recruit.disabled = true
		btn_recruit.tooltip_text = check.reason
	
	hbox.add_child(btn_recruit)
	cards_container.add_child(card)

func _on_recruit_clicked(data: UnitData) -> void:
	if production_manager == null or player_country == null or target_province == null:
		return
	
	var order = production_manager.recruit_unit(player_country, data, target_province)
	if order != null:
		# Refresh tampilan untuk update status kelayakan sumber daya
		_rebuild_cards()
