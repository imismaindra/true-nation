# building_manager.gd
# Mengelola antrian pembangunan fasilitas infrastruktur dan pabrik provinsi berbasis waktu (Ticks).
class_name BuildingManager
extends Node

class ConstructionOrder:
	var order_id: int
	var building_data: BuildingData
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

@export var player_country: Country
@export var economy_manager: EconomyManager

var active_orders: Array[ConstructionOrder] = []
var _next_order_id: int = 1

signal construction_started(order: ConstructionOrder)
signal construction_progress_updated(order: ConstructionOrder)
signal construction_completed(order: ConstructionOrder)
signal construction_cancelled(order: ConstructionOrder)

func _ready() -> void:
	var time_mgr = get_node_or_null("/root/TimeManager")
	if time_mgr != null:
		if not time_mgr.hourly_tick.is_connected(_on_hourly_tick):
			time_mgr.hourly_tick.connect(_on_hourly_tick)

func can_construct(c: Country, data: BuildingData, prov: Province) -> Dictionary:
	if c == null or data == null or prov == null:
		return { "can": false, "reason": "Data tidak valid." }
	
	if prov.owner_country != c:
		return { "can": false, "reason": "Wilayah bukan milik negara Anda." }
	
	var prov_check = prov.can_construct_building(data)
	if not prov_check.can:
		return prov_check
	
	# Cek apakah sedang dibangun fasilitas yang sama di provinsi ini
	for order in active_orders:
		if order.target_province == prov and order.building_data == data:
			return { "can": false, "reason": "Proyek bangunan ini sedang berlangsung di provinsi ini." }
	
	# Cek ketersediaan sumber daya
	if c.money < data.build_cost_money:
		return { "can": false, "reason": "Kas negara tidak cukup ($%.0f butuh $%.0f)" % [c.money, data.build_cost_money] }
	if c.steel < data.build_cost_steel:
		return { "can": false, "reason": "Baja tidak mencukupi (%.0f butuh %.0f)" % [c.steel, data.build_cost_steel] }
	if c.fuel < data.build_cost_fuel:
		return { "can": false, "reason": "Bahan bakar tidak mencukupi (%.0f butuh %.0f)" % [c.fuel, data.build_cost_fuel] }
	
	return { "can": true, "reason": "Siap dibangun." }

func start_construction(c: Country, data: BuildingData, prov: Province) -> ConstructionOrder:
	var check = can_construct(c, data, prov)
	if not check.can:
		print("⚠️ GAGAL KONSTRUKSI: %s" % check.reason)
		return null
	
	# Potong biaya konstruksi
	c.money -= data.build_cost_money
	c.steel -= data.build_cost_steel
	c.fuel -= data.build_cost_fuel
	
	var order = ConstructionOrder.new()
	order.order_id = _next_order_id
	_next_order_id += 1
	order.building_data = data
	order.target_province = prov
	order.country = c
	order.total_days = max(1, data.build_days)
	order.hours_progress = 0
	order.is_completed = false
	
	active_orders.append(order)
	construction_started.emit(order)
	
	print("🏗️ MEMULAI KONSTRUKSI: %s di %s | Durasi: %d hari" % [
		data.building_name, prov.province_name, order.total_days
	])
	
	return order

func cancel_construction(order_id: int) -> bool:
	for i in range(active_orders.size()):
		var order = active_orders[i]
		if order.order_id == order_id:
			# Refund 80% biaya
			var c = order.country
			var d = order.building_data
			if c != null and d != null:
				c.money += d.build_cost_money * 0.8
				c.steel += d.build_cost_steel * 0.8
				c.fuel += d.build_cost_fuel * 0.8
			
			active_orders.remove_at(i)
			construction_cancelled.emit(order)
			return true
	return false

func _on_hourly_tick(_hour: int, _day: int, _month: int, _year: int) -> void:
	for i in range(active_orders.size() - 1, -1, -1):
		var order = active_orders[i]
		order.hours_progress += 1
		construction_progress_updated.emit(order)
		
		if order.hours_progress >= order.total_days * 24:
			order.is_completed = true
			_complete_construction(order)
			active_orders.remove_at(i)

func _complete_construction(order: ConstructionOrder) -> void:
	if order.target_province != null and order.building_data != null:
		var ok = order.target_province.add_building(order.building_data)
		if ok:
			print("✅ KONSTRUKSI SELESAI: %s di %s!" % [
				order.building_data.building_name, order.target_province.province_name
			])
		else:
			print("⚠️ GAGAL MENEMPATKAN BANGUNAN: Slot penuh di %s." % order.target_province.province_name)
	
	# Perbarui ekonomi setelah bangunan aktif
	if economy_manager != null:
		economy_manager.recalculate_country_incomes()
	
	construction_completed.emit(order)
