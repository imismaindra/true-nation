# production_queue_panel.gd
# Menampilkan daftar antrian pelatihan divisi militer dan konstruksi fasilitas aktif.
class_name ProductionQueuePanel
extends PanelContainer

signal count_changed(count: int)

@export var production_manager: ProductionManager
@export var building_manager: Node

@onready var button_header: Button = $MarginContainer/VBox/HeaderButton
@onready var header_separator: HSeparator = $MarginContainer/VBox/HSeparator
@onready var scroll: ScrollContainer = $MarginContainer/VBox/Scroll
@onready var orders_container: VBoxContainer = $MarginContainer/VBox/Scroll/OrdersContainer

# Cache dictionary [view_key -> Dictionary of node references]
var _order_views: Dictionary = {}
var _collapsed: bool = false
var _is_open: bool = false
var _total_count: int = 0

func _ready() -> void:
	visible = false
	button_header.pressed.connect(_toggle_collapsed)
	_apply_collapsed_state()
	if production_manager != null:
		production_manager.order_started.connect(func(_o): _rebuild_queue_ui())
		production_manager.order_completed.connect(func(_o, _u): _rebuild_queue_ui())
		production_manager.order_cancelled.connect(func(_o): _rebuild_queue_ui())
		production_manager.order_progress_updated.connect(_on_unit_order_progress_updated)
	
	if building_manager != null:
		building_manager.construction_started.connect(func(_o): _rebuild_queue_ui())
		building_manager.construction_completed.connect(func(_o): _rebuild_queue_ui())
		building_manager.construction_cancelled.connect(func(_o): _rebuild_queue_ui())
		building_manager.construction_progress_updated.connect(_on_bld_order_progress_updated)
	
	_rebuild_queue_ui()
	get_viewport().size_changed.connect(_fit_to_viewport)

func _fit_to_viewport() -> void:
	if not visible:
		return
	var max_height = get_viewport_rect().size.y - global_position.y - 16.0
	if _collapsed:
		size.y = get_combined_minimum_size().y
		return
	var scroll_min = scroll.get_combined_minimum_size().y
	var desired_height = get_combined_minimum_size().y - scroll_min + orders_container.get_combined_minimum_size().y
	size.y = maxf(0.0, minf(desired_height, max_height))

func _toggle_collapsed() -> void:
	_collapsed = not _collapsed
	_apply_collapsed_state()
	call_deferred("_fit_to_viewport")

func _apply_collapsed_state() -> void:
	scroll.visible = not _collapsed
	header_separator.visible = not _collapsed
	var arrow = ">" if _collapsed else "v"
	button_header.text = "%s LOGISTIK & KONSTRUKSI (%d)" % [arrow, _total_count]

func get_order_count() -> int:
	return _total_count

func toggle_panel() -> void:
	_is_open = not _is_open
	_update_visibility()

func _update_visibility() -> void:
	visible = _is_open and _total_count > 0
	if visible:
		call_deferred("_fit_to_viewport")

func _rebuild_queue_ui() -> void:
	_order_views.clear()
	for child in orders_container.get_children():
		child.queue_free()
	
	var unit_orders_count = production_manager.active_orders.size() if production_manager else 0
	var bld_orders_count = building_manager.active_orders.size() if building_manager else 0
	var total_count = unit_orders_count + bld_orders_count
	_total_count = total_count
	_apply_collapsed_state()
	count_changed.emit(_total_count)
	
	if total_count == 0:
		_update_visibility()
		return
	
	_update_visibility()
	
	# 1. Antrian Unit Militer
	if production_manager != null:
		for order in production_manager.active_orders:
			_create_unit_order_view(order)
	
	# 2. Antrian Konstruksi Bangunan
	if building_manager != null:
		for bld_order in building_manager.active_orders:
			_create_bld_order_view(bld_order)
	
	call_deferred("_fit_to_viewport")

func _create_unit_order_view(order: ProductionManager.ProductionOrder) -> void:
	var item_box = VBoxContainer.new()
	item_box.add_theme_constant_override("separation", 3)
	
	var hbox_top = HBoxContainer.new()
	hbox_top.add_theme_constant_override("separation", 6)
	
	# Texture Icon Matra Taktis
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(16, 16)
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if order.unit_data != null:
		icon_rect.texture = order.unit_data.get_tactical_symbol_texture()
	hbox_top.add_child(icon_rect)
	
	var label_title = Label.new()
	label_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var unit_name = order.unit_data.unit_name if order.unit_data else "Divisi"
	var prov_name = order.target_province.province_name if order.target_province else "Wilayah"
	label_title.text = "%s (%s)" % [unit_name.substr(0, 14), prov_name]
	label_title.add_theme_font_size_override("font_size", 11)
	hbox_top.add_child(label_title)
	
	# Tombol Batal
	var btn_cancel = Button.new()
	btn_cancel.text = "X"
	btn_cancel.custom_minimum_size = Vector2(18, 18)
	btn_cancel.tooltip_text = "Batalkan pesanan (Refund 80% biaya)"
	btn_cancel.pressed.connect(func(): _on_cancel_unit_order(order.order_id))
	hbox_top.add_child(btn_cancel)
	
	item_box.add_child(hbox_top)
	
	# Progress bar
	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 8)
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
	_order_views["u_%d" % order.order_id] = {
		"bar": bar,
		"label_info": label_info
	}

func _create_bld_order_view(order) -> void:
	var item_box = VBoxContainer.new()
	item_box.add_theme_constant_override("separation", 3)
	
	var hbox_top = HBoxContainer.new()
	hbox_top.add_theme_constant_override("separation", 6)
	
	# Texture Icon Bangunan Taktis
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(16, 16)
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if order.building_data != null:
		icon_rect.texture = order.building_data.get_icon_texture()
	hbox_top.add_child(icon_rect)
	
	var label_title = Label.new()
	label_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bld_name = order.building_data.building_name if order.building_data else "Fasilitas"
	var prov_name = order.target_province.province_name if order.target_province else "Wilayah"
	label_title.text = "%s (%s)" % [bld_name.substr(0, 14), prov_name]
	label_title.add_theme_font_size_override("font_size", 11)
	label_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	hbox_top.add_child(label_title)
	
	# Tombol Batal
	var btn_cancel = Button.new()
	btn_cancel.text = "X"
	btn_cancel.custom_minimum_size = Vector2(18, 18)
	btn_cancel.tooltip_text = "Batalkan konstruksi (Refund 80% biaya)"
	btn_cancel.pressed.connect(func(): _on_cancel_bld_order(order.order_id))
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
	label_info.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6, 0.9))
	item_box.add_child(label_info)
	
	orders_container.add_child(item_box)
	_order_views["b_%d" % order.order_id] = {
		"bar": bar,
		"label_info": label_info
	}

func _on_unit_order_progress_updated(order: ProductionManager.ProductionOrder) -> void:
	var key = "u_%d" % order.order_id
	if _order_views.has(key):
		var view = _order_views[key]
		var ratio = order.get_progress_ratio()
		view["bar"].value = ratio * 100.0
		view["label_info"].text = "%.1f hari tersisa (%.0f%%)" % [order.get_days_remaining(), ratio * 100.0]

func _on_bld_order_progress_updated(order) -> void:
	var key = "b_%d" % order.order_id
	if _order_views.has(key):
		var view = _order_views[key]
		var ratio = order.get_progress_ratio()
		view["bar"].value = ratio * 100.0
		view["label_info"].text = "%.1f hari tersisa (%.0f%%)" % [order.get_days_remaining(), ratio * 100.0]

func _on_cancel_unit_order(order_id: int) -> void:
	if production_manager != null:
		production_manager.cancel_order(order_id)

func _on_cancel_bld_order(order_id: int) -> void:
	if building_manager != null:
		building_manager.cancel_construction(order_id)
