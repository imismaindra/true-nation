# production_manager.gd
# Mengelola antrian rekrutmen dan manufaktur divisi militer berbasis waktu (Ticks).
class_name ProductionManager
extends Node

class ProductionOrder:
	var order_id: int
	var unit_data: UnitData
	var target_province: Province
	var country: Country
	var total_days: int
	var hours_progress: int = 0
	var is_completed: bool = false
	
	var days_progress: float:
		get:
			return float(hours_progress) / 24.0
	
	func get_progress_ratio() -> float:
		var total_hours = total_days * 24
		if total_hours <= 0:
			return 1.0
		return clampf(float(hours_progress) / float(total_hours), 0.0, 1.0)
	
	func get_days_remaining() -> float:
		var total_hours = total_days * 24
		var hours_left = max(0, total_hours - hours_progress)
		return float(hours_left) / 24.0

@export var military_manager: MilitaryManager
@export var player_country: Country

var active_orders: Array[ProductionOrder] = []
var _next_order_id: int = 1

signal order_started(order: ProductionOrder)
signal order_progress_updated(order: ProductionOrder)
signal order_completed(order: ProductionOrder, unit_node: MilitaryUnit)
signal order_cancelled(order: ProductionOrder)

func _ready() -> void:
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		# Update progres setiap jam secara presisi (1 hari = 24 jam)
		if not time_mgr.hourly_tick.is_connected(_on_hourly_tick):
			time_mgr.hourly_tick.connect(_on_hourly_tick)
	
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null and event_bus.has_signal("province_owner_changed"):
		event_bus.province_owner_changed.connect(_on_province_owner_changed)

func _on_province_owner_changed(province_node, old_owner, new_owner) -> void:
	if province_node == null or old_owner == null or old_owner == new_owner:
		return
	for i in range(active_orders.size() - 1, -1, -1):
		var order = active_orders[i]
		if order.target_province == province_node and order.country == old_owner:
			print("[RECRUIT] DIBATALKAN: %s jatuh ke pihak lain sebelum %s selesai dilatih." % [
				province_node.province_name, order.unit_data.unit_name
			])
			cancel_order(order.order_id)

func can_recruit(c: Country, data: UnitData, prov: Province) -> Dictionary:
	if c == null or data == null or prov == null:
		return { "can": false, "reason": "Data tidak valid." }
	
	if prov.owner_country != c:
		return { "can": false, "reason": "Wilayah bukan milik negara Anda." }
	
	# Domain & Facility check
	if data.domain == UnitData.Domain.SEA:
		if not prov.is_sea_zone() and prov.terrain != Province.TerrainType.COASTAL:
			return { "can": false, "reason": "Armada laut hanya bisa dibuat di wilayah pesisir / laut." }
		if not prov.has_naval_base():
			return { "can": false, "reason": "Membutuhkan Pangkalan Angkatan Laut (Naval Dockyard) di wilayah ini." }
	elif data.domain == UnitData.Domain.AIR:
		if prov.is_sea_zone():
			return { "can": false, "reason": "Jet tempur tidak dapat dirakit di zona laut lepas." }
		if not prov.has_airbase():
			return { "can": false, "reason": "Membutuhkan Pangkalan Angkatan Udara (Airbase) di wilayah ini." }
	elif data.domain == UnitData.Domain.LAND:
		if prov.is_sea_zone():
			return { "can": false, "reason": "Pasukan darat tidak dapat dilatih di zona laut lepas." }
	
	# Resource checks
	if c.money < data.production_cost_money:
		return { "can": false, "reason": "Kas negara tidak cukup ($%.0f butuh $%.0f)" % [c.money, data.production_cost_money] }
	if c.steel < data.production_cost_steel:
		return { "can": false, "reason": "Baja tidak mencukupi (%.0f butuh %.0f)" % [c.steel, data.production_cost_steel] }
	if c.fuel < data.production_cost_fuel:
		return { "can": false, "reason": "Bahan bakar tidak mencukupi (%.0f butuh %.0f)" % [c.fuel, data.production_cost_fuel] }
	if c.manpower < data.required_manpower:
		return { "can": false, "reason": "Cadangan Manpower tidak cukup (%d butuh %d)" % [c.manpower, data.required_manpower] }
	if c.arms < data.production_cost_arms:
		return { "can": false, "reason": "Persenjataan tidak cukup (%.0f butuh %.0f)" % [c.arms, data.production_cost_arms] }
	if c.munitions < data.production_cost_munitions:
		return { "can": false, "reason": "Bekal Amunisi tidak cukup (%.0f butuh %.0f)" % [c.munitions, data.production_cost_munitions] }
	
	return { "can": true, "reason": "Siap dilatih." }

func recruit_unit(c: Country, data: UnitData, prov: Province) -> ProductionOrder:
	var check = can_recruit(c, data, prov)
	if not check.can:
		print("[WARN] GAGAL REKRUT: %s" % check.reason)
		return null
	
	# Potong sumber daya negara
	c.money -= data.production_cost_money
	c.steel -= data.production_cost_steel
	c.fuel -= data.production_cost_fuel
	c.manpower -= data.required_manpower
	c.arms -= data.production_cost_arms
	c.munitions -= data.production_cost_munitions
	
	var order = ProductionOrder.new()
	order.order_id = _next_order_id
	_next_order_id += 1
	order.unit_data = data
	order.target_province = prov
	order.country = c
	order.total_days = max(1, data.production_days)
	order.hours_progress = 0
	order.is_completed = false
	
	active_orders.append(order)
	order_started.emit(order)
	
	print("[RECRUIT] MEMULAI REKRUTMEN: %s di %s | Durasi: %d hari" % [
		data.unit_name, prov.province_name, order.total_days
	])
	
	return order

func cancel_order(order_id: int) -> bool:
	for i in range(active_orders.size()):
		var order = active_orders[i]
		if order.order_id == order_id:
			# Refund 80% biaya
			var c = order.country
			var d = order.unit_data
			if c != null and d != null:
				c.money += d.production_cost_money * 0.8
				c.steel += d.production_cost_steel * 0.8
				c.fuel += d.production_cost_fuel * 0.8
				c.manpower += int(float(d.required_manpower) * 0.8)
				c.arms += d.production_cost_arms * 0.8
				c.munitions += d.production_cost_munitions * 0.8
			
			active_orders.remove_at(i)
			order_cancelled.emit(order)
			return true
	return false

func _on_hourly_tick(_hour: int, _day: int, _month: int, _year: int) -> void:
	for i in range(active_orders.size() - 1, -1, -1):
		var order = active_orders[i]
		order.hours_progress += 1
		order_progress_updated.emit(order)
		
		if order.hours_progress >= order.total_days * 24:
			order.is_completed = true
			_complete_order(order)
			active_orders.remove_at(i)

func _complete_order(order: ProductionOrder) -> void:
	if military_manager == null:
		print("[ERROR] GAGAL DEPLOY: MilitaryManager tidak terhubung.")
		return
	
	if order.country == null or order.target_province == null or order.target_province.owner_country != order.country:
		print("[RECRUIT] DEPLOY DIBATALKAN: %s tidak lagi memiliki %s." % [
			order.country.country_name if order.country != null else "Negara",
			order.target_province.province_name if order.target_province != null else "wilayah target"
		])
		order_cancelled.emit(order)
		return
	
	var unit_inst = military_manager.spawn_unit(order.unit_data, order.country, order.target_province)
	order_completed.emit(order, unit_inst)
