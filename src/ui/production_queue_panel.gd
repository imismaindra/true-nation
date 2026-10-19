# production_queue_panel.gd
# Menampilkan daftar antrian pelatihan divisi dan manufaktur militer aktif.
class_name ProductionQueuePanel
extends PanelContainer

@export var production_manager: ProductionManager

@onready var label_header: Label = $MarginContainer/VBox/LabelHeader
@onready var orders_container: VBoxContainer = $MarginContainer/VBox/OrdersContainer

# Cache dictionary [order_id -> Dictionary of node references]
var _order_views: Dictionary = {}

func _ready() -> void:
	visible = false
	if production_manager != null:
		production_manager.order_started.connect(func(_o): _rebuild_queue_ui())
		production_manager.order_completed.connect(func(_o, _u): _rebuild_queue_ui())
		production_manager.order_cancelled.connect(func(_o): _rebuild_queue_ui())
		production_manager.order_progress_updated.connect(_on_order_progress_updated)
	
	_rebuild_queue_ui()

func _rebuild_queue_ui() -> void:
	_order_views.clear()
	for child in orders_container.get_children():
		child.queue_free()
	
	if production_manager == null or production_manager.active_orders.is_empty():
		visible = false
		return
	
	visible = true
	label_header.text = "🏭 ANTRIAN PRODUKSI (%d)" % production_manager.active_orders.size()
	
	for order in production_manager.active_orders:
		_create_order_view(order)

func _create_order_view(order: ProductionManager.ProductionOrder) -> void:
	var item_box = VBoxContainer.new()
	item_box.add_theme_constant_override("separation", 3)
	
	var hbox_top = HBoxContainer.new()
	
	# Icon Matra
	var icon_str = "🪖"
	if order.unit_data != null:
		match order.unit_data.domain:
			UnitData.Domain.LAND:
				icon_str = "🚜" if order.unit_data.hard_attack > 10 else "🪖"
			UnitData.Domain.SEA:
				icon_str = "🚢"
			UnitData.Domain.AIR:
				icon_str = "✈️"
	
	var label_title = Label.new()
	label_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var unit_name = order.unit_data.unit_name if order.unit_data else "Divisi"
	var prov_name = order.target_province.province_name if order.target_province else "Wilayah"
	label_title.text = "%s %s (%s)" % [icon_str, unit_name.substr(0, 14), prov_name]
	label_title.add_theme_font_size_override("font_size", 11)
	hbox_top.add_child(label_title)
	
	# Tombol Batal
	var btn_cancel = Button.new()
	btn_cancel.text = "✕"
	btn_cancel.custom_minimum_size = Vector2(18, 18)
	btn_cancel.tooltip_text = "Batalkan pesanan (Refund 80% biaya)"
	btn_cancel.pressed.connect(func(): _on_cancel_order(order.order_id))
	hbox_top.add_child(btn_cancel)
	
	item_box.add_child(hbox_top)
	
	# Progress bar
	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 10)
	bar.show_percentage = false
	bar.value = order.get_progress_ratio() * 100.0
	item_box.add_child(bar)
	
	# Subtitle hari tersisa
	var label_info = Label.new()
	label_info.text = "%.1f hari tersisa (%.0f%%)" % [order.get_days_remaining(), bar.value]
	label_info.add_theme_font_size_override("font_size", 10)
	label_info.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.9))
	item_box.add_child(label_info)
	
	orders_container.add_child(item_box)
	_order_views[order.order_id] = {
		"bar": bar,
		"label_info": label_info
	}

func _on_order_progress_updated(order: ProductionManager.ProductionOrder) -> void:
	if _order_views.has(order.order_id):
		var view = _order_views[order.order_id]
		var ratio = order.get_progress_ratio()
		view["bar"].value = ratio * 100.0
		view["label_info"].text = "%.1f hari tersisa (%.0f%%)" % [order.get_days_remaining(), ratio * 100.0]

func _on_cancel_order(order_id: int) -> void:
	if production_manager != null:
		production_manager.cancel_order(order_id)
