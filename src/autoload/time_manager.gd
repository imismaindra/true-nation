# time_manager.gd
# Singleton pengelola jam dunia, kecepatan, pause, dan detak waktu (Ticks).
extends Node

enum GameSpeed {
	PAUSED = 0,
	NORMAL = 1,      # 1 detik = 1 jam game
	FAST = 2,        # 0.5 detik = 1 jam game
	VERY_FAST = 3,   # 0.2 detik = 1 jam game
	SUPER_FAST = 5   # 0.1 detik = 1 jam game
}

# Kecepatan dasar: 1 jam dalam game membutuhkan 1.0 detik real-time pada kecepatan NORMAL (1x)
const BASE_SECONDS_PER_HOUR: float = 1.0

# Sinyal Waktu
signal speed_changed(new_speed: int)
signal pause_toggled(is_paused: bool)
signal hourly_tick(hour: int, day: int, month: int, year: int)
signal daily_tick(day: int, month: int, year: int)
signal monthly_tick(month: int, year: int)

# State Waktu
@export var hour: int = 6       # Mulai jam 06:00 pagi
@export var day: int = 1        # Hari ke-1
@export var month: int = 1      # Januari
@export var year: int = 2026    # Tahun 2026

var current_speed: int = GameSpeed.PAUSED
var previous_speed: int = GameSpeed.NORMAL
var is_paused: bool = true

# Akumulasi delta
var _time_accumulator: float = 0.0

const MONTH_NAMES: Array[String] = [
	"", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
	"Juli", "Agustus", "September", "Oktober", "November", "Desember"
]

const DAYS_IN_MONTH: Array[int] = [
	0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
]

func _ready() -> void:
	# Default game dimulai dalam keadaan PAUSED agar pemain bisa melihat peta terlebih dahulu
	set_speed(GameSpeed.PAUSED)

func _process(delta: float) -> void:
	if is_paused or current_speed == GameSpeed.PAUSED:
		return
	
	_time_accumulator += delta * float(current_speed)
	
	while _time_accumulator >= BASE_SECONDS_PER_HOUR:
		_time_accumulator -= BASE_SECONDS_PER_HOUR
		_advance_hour()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	
	match event.keycode:
		KEY_SPACE:
			toggle_pause()
			get_viewport().set_input_as_handled()
		KEY_1:
			set_speed(GameSpeed.NORMAL)
			get_viewport().set_input_as_handled()
		KEY_2:
			set_speed(GameSpeed.FAST)
			get_viewport().set_input_as_handled()
		KEY_3:
			set_speed(GameSpeed.VERY_FAST)
			get_viewport().set_input_as_handled()
		KEY_4, KEY_5:
			set_speed(GameSpeed.SUPER_FAST)
			get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if is_paused:
		resume()
	else:
		pause()

func pause() -> void:
	if not is_paused:
		previous_speed = current_speed if current_speed != GameSpeed.PAUSED else GameSpeed.NORMAL
		current_speed = GameSpeed.PAUSED
		is_paused = true
		pause_toggled.emit(true)
		speed_changed.emit(current_speed)

func resume() -> void:
	if is_paused:
		current_speed = previous_speed
		is_paused = false
		pause_toggled.emit(false)
		speed_changed.emit(current_speed)

func set_speed(speed: int) -> void:
	if speed == GameSpeed.PAUSED:
		pause()
		return
	
	previous_speed = speed
	current_speed = speed
	is_paused = false
	pause_toggled.emit(false)
	speed_changed.emit(current_speed)

func _advance_hour() -> void:
	hour += 1
	if hour >= 24:
		hour = 0
		_advance_day()
	
	hourly_tick.emit(hour, day, month, year)

func _advance_day() -> void:
	day += 1
	var max_days = DAYS_IN_MONTH[month]
	# Cek tahun kabisat untuk Februari
	if month == 2 and _is_leap_year(year):
		max_days = 29
	
	if day > max_days:
		day = 1
		_advance_month()
	
	daily_tick.emit(day, month, year)

func _advance_month() -> void:
	month += 1
	if month > 12:
		month = 1
		year += 1
	
	monthly_tick.emit(month, year)

func _is_leap_year(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)

# Helper Format Waktu & Tanggal untuk UI
func get_formatted_time() -> String:
	return "%02d:00" % hour

func get_formatted_date() -> String:
	return "%d %s %d" % [day, MONTH_NAMES[month], year]

func get_formatted_full() -> String:
	return "%02d:00 | %d %s %d" % [hour, day, MONTH_NAMES[month], year]
