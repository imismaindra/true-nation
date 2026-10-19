# time_controls.gd
# Mengontrol tampilan visual jam dan tombol kecepatan waktu pada UI.
extends PanelContainer

@onready var label_time: Label = $MarginContainer/HBoxContainer/LabelTime
@onready var label_date: Label = $MarginContainer/HBoxContainer/LabelDate
@onready var btn_pause: Button = $MarginContainer/HBoxContainer/SpeedButtons/BtnPause
@onready var btn_speed_1: Button = $MarginContainer/HBoxContainer/SpeedButtons/BtnSpeed1
@onready var btn_speed_2: Button = $MarginContainer/HBoxContainer/SpeedButtons/BtnSpeed2
@onready var btn_speed_3: Button = $MarginContainer/HBoxContainer/SpeedButtons/BtnSpeed3
@onready var btn_speed_5: Button = $MarginContainer/HBoxContainer/SpeedButtons/BtnSpeed5

var _time_mgr: Node = null

func _ready() -> void:
	_time_mgr = get_node_or_null("/root/TimeManager")
	if _time_mgr == null:
		return
	
	# Hubungkan sinyal dari TimeManager
	_time_mgr.hourly_tick.connect(_on_hourly_tick)
	_time_mgr.speed_changed.connect(_on_speed_changed)
	_time_mgr.pause_toggled.connect(_on_pause_toggled)
	
	# Hubungkan klik tombol
	btn_pause.pressed.connect(func(): _time_mgr.toggle_pause())
	btn_speed_1.pressed.connect(func(): _time_mgr.set_speed(1))
	btn_speed_2.pressed.connect(func(): _time_mgr.set_speed(2))
	btn_speed_3.pressed.connect(func(): _time_mgr.set_speed(3))
	btn_speed_5.pressed.connect(func(): _time_mgr.set_speed(5))
	
	# Refresh awal
	_update_display()
	_update_button_states(_time_mgr.current_speed, _time_mgr.is_paused)

func _on_hourly_tick(_hour: int, _day: int, _month: int, _year: int) -> void:
	_update_display()

func _on_speed_changed(new_speed: int) -> void:
	if _time_mgr:
		_update_button_states(new_speed, _time_mgr.is_paused)

func _on_pause_toggled(is_paused: bool) -> void:
	if _time_mgr:
		_update_button_states(_time_mgr.current_speed, is_paused)

func _update_display() -> void:
	if _time_mgr:
		label_time.text = _time_mgr.get_formatted_time()
		label_date.text = _time_mgr.get_formatted_date()

func _update_button_states(speed: int, is_paused: bool) -> void:
	# Reset warna/tampilan aktif
	var active_color = Color(0.2, 0.8, 0.4, 1.0) # Hijau aktif
	var normal_color = Color(1.0, 1.0, 1.0, 0.8)
	var paused_color = Color(0.9, 0.3, 0.3, 1.0) # Merah saat pause
	
	btn_pause.modulate = paused_color if is_paused else normal_color
	btn_speed_1.modulate = active_color if (not is_paused and speed == 1) else normal_color
	btn_speed_2.modulate = active_color if (not is_paused and speed == 2) else normal_color
	btn_speed_3.modulate = active_color if (not is_paused and speed == 3) else normal_color
	btn_speed_5.modulate = active_color if (not is_paused and speed == 5) else normal_color
