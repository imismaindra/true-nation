# top_bar.gd
# Mengontrol tampilan visual HUD atas (Negara, Kas, Baja, Minyak, Manpower, dan Waktu).
extends PanelContainer

@export var player_country: Country
@export var economy_manager: Node
@export var production_queue_panel: ProductionQueuePanel

const DELTA_POS_COLOR := Color(0.55, 0.78, 0.62)
const DELTA_NEG_COLOR := Color(0.88, 0.50, 0.50)

@onready var color_rect_flag: ColorRect = $MarginContainer/HBoxContainer/CountrySection/FlagFrame/ColorRectFlag
@onready var label_country_name: Label = $MarginContainer/HBoxContainer/CountrySection/TitleBox/LabelCountryName

@onready var box_money: Control = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxMoney
@onready var box_steel: Control = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxSteel
@onready var box_fuel: Control = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxFuel
@onready var box_manpower: Control = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxManpower
@onready var box_arms: Control = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxArms
@onready var box_munitions: Control = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxMunitions

@onready var label_money: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxMoney/Values/LabelMoneyValue
@onready var label_steel: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxSteel/Values/LabelSteelValue
@onready var label_fuel: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxFuel/Values/LabelFuelValue
@onready var label_manpower: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxManpower/Values/LabelManpowerValue
@onready var label_arms: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxArms/Values/LabelArmsValue
@onready var label_munitions: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxMunitions/Values/LabelMunitionsValue

@onready var label_money_delta: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxMoney/Values/LabelMoneyDelta
@onready var label_steel_delta: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxSteel/Values/LabelSteelDelta
@onready var label_fuel_delta: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxFuel/Values/LabelFuelDelta
@onready var label_manpower_delta: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxManpower/Values/LabelManpowerDelta
@onready var label_arms_delta: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxArms/Values/LabelArmsDelta
@onready var label_munitions_delta: Label = $MarginContainer/HBoxContainer/ResourceSection/ResourceHBox/BoxMunitions/Values/LabelMunitionsDelta

@onready var btn_logistics: Button = $MarginContainer/HBoxContainer/SaveLoadSection/BtnLogistics
@onready var btn_menu: MenuButton = $MarginContainer/HBoxContainer/SaveLoadSection/BtnMenu

const ICON_SAVE := preload("res://assets/sprites/ui/icon_save.svg")
const ICON_LOAD := preload("res://assets/sprites/ui/icon_load.svg")

func _ready() -> void:
	if economy_manager != null and economy_manager.has_signal("economy_updated"):
		economy_manager.economy_updated.connect(_on_economy_updated)
	
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		time_mgr.daily_tick.connect(func(_d, _m, _y): _update_display())
	
	_setup_menu()
	
	if production_queue_panel != null:
		production_queue_panel.count_changed.connect(_on_queue_count_changed)
		btn_logistics.pressed.connect(production_queue_panel.toggle_panel)
		_on_queue_count_changed(production_queue_panel.get_order_count())
	
	_update_display()

func _setup_menu() -> void:
	var popup: PopupMenu = btn_menu.get_popup()
	popup.add_item("Simpan", 0)
	popup.set_item_icon(0, ICON_SAVE)
	popup.add_item("Muat", 1)
	popup.set_item_icon(1, ICON_LOAD)
	popup.id_pressed.connect(_on_menu_selected)

func _on_menu_selected(id: int) -> void:
	if id == 0:
		_on_save_pressed()
	elif id == 1:
		_on_load_pressed()

func _on_queue_count_changed(count: int) -> void:
	btn_logistics.text = "LOGISTIK (%d)" % count

func _on_save_pressed() -> void:
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr != null:
		save_mgr.save_game()

func _on_load_pressed() -> void:
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr != null:
		save_mgr.load_game()

func _on_economy_updated(_country: Country) -> void:
	_update_display()

func _update_display() -> void:
	if player_country == null:
		return
	
	# Info Negara
	color_rect_flag.color = player_country.map_color
	label_country_name.text = player_country.country_name
	
	# Kas Negara
	label_money.text = _format_currency(player_country.money)
	_set_delta(label_money_delta, player_country.daily_income_money)
	
	# Baja
	label_steel.text = "%.0f" % player_country.steel
	_set_delta(label_steel_delta, player_country.daily_income_steel)
	
	# Bahan Bakar
	label_fuel.text = "%.0f" % player_country.fuel
	_set_delta(label_fuel_delta, player_country.daily_income_fuel)
	
	# Manpower
	label_manpower.text = _format_manpower(player_country.manpower)
	_set_delta(label_manpower_delta, player_country.daily_manpower_growth)
	
	# Persenjataan (Arms)
	label_arms.text = "%.0f" % player_country.arms
	_set_delta(label_arms_delta, player_country.daily_income_arms)
	
	# Amunisi & Rudal (Munitions)
	label_munitions.text = "%.0f" % player_country.munitions
	_set_delta(label_munitions_delta, player_country.daily_income_munitions)
	
	# Tooltip Rincian Neraca Ekonomi Interaktif (Sprint 4)
	if economy_manager != null and economy_manager.has_method("get_economic_breakdown"):
		var b = economy_manager.get_economic_breakdown(player_country)
		
		# Tooltip Kas
		box_money.tooltip_text = (
			"[KAS NEGARA]\n" +
			"• Pendapatan Wilayah: +$%.1f/hari\n" % b.money.income_prov +
			"• Biaya Operasional Pabrik: -$%.1f/hari\n" % b.money.expense_buildings +
			"• Pemeliharaan Divisi Militer: -$%.1f/hari\n" % b.money.expense_units +
			"------------------------------------\n" +
			"• Total Pendapatan: +$%.1f/hari\n" % b.money.total_income +
			"• Total Pengeluaran: -$%.1f/hari\n" % b.money.total_expense +
			"• Surplus / Defisit Bersih: %s$%.1f/hari" % ["+" if b.money.net >= 0 else "", b.money.net]
		)
		
		# Tooltip Baja
		box_steel.tooltip_text = (
			"[INDUSTRI BAJA]\n" +
			"• Tambang Wilayah: +%.1f ton/hari\n" % b.steel.output_prov +
			"• Pabrik Peleburan Baja: +%.1f ton/hari\n" % b.steel.output_buildings +
			"• Konsumsi Industri Manufaktur: -%.1f ton/hari\n" % b.steel.input_buildings +
			"------------------------------------\n" +
			"• Surplus Bersih: %s%.1f ton/hari" % ["+" if b.steel.net >= 0 else "", b.steel.net]
		)
		
		# Tooltip Bahan Bakar
		box_fuel.tooltip_text = (
			"[BAHAN BAKAR & MINYAK]\n" +
			"• Ladang Minyak: +%.1f barel/hari\n" % b.fuel.output_prov +
			"• Kilang Minyak Aktif: +%.1f barel/hari\n" % b.fuel.output_refinery +
			"• Konsumsi Industri: -%.1f barel/hari\n" % b.fuel.input_buildings +
			"• Konsumsi Armada & Pasukan: -%.1f barel/hari\n" % b.fuel.consumption_units +
			"------------------------------------\n" +
			"• Surplus Bersih: %s%.1f barel/hari" % ["+" if b.fuel.net >= 0 else "", b.fuel.net]
		)
		
		# Tooltip Manpower
		box_manpower.tooltip_text = (
			"[TENAGA MANUSIA - MANPOWER]\n" +
			"• Total Populasi Negara: %s jiwa\n" % _format_number(b.manpower.total_population) +
			"• Pertumbuhan / Rekrutmen: +%d personel/hari\n" % b.manpower.growth_daily +
			"• Digunakan untuk melatih divisi baru & mengisi personel tempur."
		)
		
		# Tooltip Persenjataan
		box_arms.tooltip_text = (
			"[PERSENJATAAN INFANTERI]\n" +
			"• Produksi Pabrik Senjata: +%.1f unit/hari\n" % b.arms.output_factories +
			"• Digunakan saat pelatihan divisi baru."
		)
		
		# Tooltip Amunisi
		box_munitions.tooltip_text = (
			"[AMUNISI & LOGISTIK TEMPUR]\n" +
			"• Produksi Pabrik Amunisi: +%.1f peti/hari\n" % b.munitions.output_plants +
			"• Dikonsumsi oleh divisi saat bertempur aktif.\n" +
			"[PERINGATAN] Pasukan tanpa amunisi menderita penalti tempur -50%!"
		)

func _set_delta(label: Label, value: float) -> void:
	label.text = ("+" if value >= 0.0 else "") + str(int(round(value)))
	label.modulate = DELTA_POS_COLOR if value >= 0.0 else DELTA_NEG_COLOR

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

func _format_number(n: int) -> String:
	if n >= 1000000:
		return "%.1f Juta" % (float(n) / 1000000.0)
	elif n >= 1000:
		return "%d Ribu" % int(float(n) / 1000.0)
	return str(n)
