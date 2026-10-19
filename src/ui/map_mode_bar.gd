# map_mode_bar.gd
# Bilah kontrol cepat tampilan teater operasi taktis (Fokus Ibu Kota, Reset Zoom, Mode C4ISR).
extends PanelContainer

@export var camera: RTSCamera2D

@onready var btn_capital: Button = $MarginContainer/HBoxContainer/BtnCapital
@onready var btn_reset: Button = $MarginContainer/HBoxContainer/BtnReset
@onready var btn_c4isr: Button = $MarginContainer/HBoxContainer/BtnC4ISR

func _ready() -> void:
	if camera == null:
		camera = get_tree().root.find_child("RTSCamera2D", true, false) as RTSCamera2D
	
	btn_capital.pressed.connect(_on_capital_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_c4isr.pressed.connect(_on_c4isr_pressed)

func _on_capital_pressed() -> void:
	if camera != null:
		# Koordinat Ibu Kota Batavia di Pulau Jawa
		camera.focus_on(Vector2(-535, 210), 0.80)

func _on_reset_pressed() -> void:
	if camera != null:
		# Peta penuh panorama nusantara Sabang s/d Merauke
		camera.focus_on(Vector2(0, 0), 0.48)

func _on_c4isr_pressed() -> void:
	var fog_mgr = get_tree().root.find_child("FogOfWarManager", true, false)
	if fog_mgr != null:
		fog_mgr.update_fog_of_war()
