# rts_camera_2d.gd
# Kamera 2D RTS/Grand Strategy dengan kontrol Pan (WASD/Drag) dan Zoom halus ke posisi kursor.
class_name RTSCamera2D
extends Camera2D

@export_group("Pan Settings")
@export var base_pan_speed: float = 800.0          # Kecepatan gerak kamera keyboard (pixel/detik)
@export var enable_edge_scrolling: bool = false    # Gerak saat mouse di tepi layar
@export var edge_margin: float = 25.0              # Jarak tepi layar (pixel)
@export var drag_button: MouseButton = MOUSE_BUTTON_MIDDLE # Tombol mouse untuk drag pan (tengah)

@export_group("Zoom Settings")
@export var min_zoom_level: float = 0.25           # Zoom terjauh (peta global)
@export var max_zoom_level: float = 3.0            # Zoom terdekat (detail provinsi)
@export var zoom_factor: float = 0.15              # Kelipatan perubahan per scroll
@export var zoom_smoothness: float = 12.0          # Kecepatan lerp zoom

@export_group("Camera Bounds")
@export var enable_limits: bool = true
@export var map_bounds: Rect2 = Rect2(-3000, -3000, 6000, 6000)

var _target_zoom: Vector2 = Vector2.ONE
var _is_dragging: bool = false
var _drag_start_mouse_pos: Vector2 = Vector2.ZERO
var _drag_start_cam_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_target_zoom = zoom
	if enable_limits:
		limit_left = int(map_bounds.position.x)
		limit_top = int(map_bounds.position.y)
		limit_right = int(map_bounds.position.x + map_bounds.size.x)
		limit_bottom = int(map_bounds.position.y + map_bounds.size.y)

func _process(delta: float) -> void:
	_handle_keyboard_and_edge_pan(delta)
	_handle_smooth_zoom(delta)

func _handle_keyboard_and_edge_pan(delta: float) -> void:
	if _is_dragging:
		return
	
	var input_vector = Vector2.ZERO
	
	# Input Keyboard (WASD atau Panah)
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1
	
	# Edge Scrolling (bila diaktifkan)
	if enable_edge_scrolling and input_vector == Vector2.ZERO:
		var mouse_pos = get_viewport().get_mouse_position()
		var viewport_size = get_viewport_rect().size
		
		if mouse_pos.x <= edge_margin:
			input_vector.x -= 1
		elif mouse_pos.x >= viewport_size.x - edge_margin:
			input_vector.x += 1
		
		if mouse_pos.y <= edge_margin:
			input_vector.y -= 1
		elif mouse_pos.y >= viewport_size.y - edge_margin:
			input_vector.y += 1
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		# Kecepatan gerak disesuaikan dengan zoom (saat zoom out, kamera bergerak lebih cepat)
		var actual_speed = (base_pan_speed / zoom.x) * delta
		position += input_vector * actual_speed
		_clamp_position()

func _handle_smooth_zoom(delta: float) -> void:
	if zoom.distance_to(_target_zoom) > 0.001:
		zoom = zoom.lerp(_target_zoom, delta * zoom_smoothness)

func _unhandled_input(event: InputEvent) -> void:
	# Zoom via Mouse Wheel
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_towards_mouse(1.0 + zoom_factor, event.position)
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_towards_mouse(1.0 - zoom_factor, event.position)
				get_viewport().set_input_as_handled()
			elif event.button_index == drag_button:
				_is_dragging = true
				_drag_start_mouse_pos = event.position
				_drag_start_cam_pos = position
				get_viewport().set_input_as_handled()
		elif not event.is_pressed() and event.button_index == drag_button:
			_is_dragging = false
			get_viewport().set_input_as_handled()
	
	# Drag Pan via Mouse Motion
	elif event is InputEventMouseMotion and _is_dragging:
		var mouse_delta = (_drag_start_mouse_pos - event.position) / zoom.x
		position = _drag_start_cam_pos + mouse_delta
		_clamp_position()
		get_viewport().set_input_as_handled()

func _zoom_towards_mouse(factor: float, mouse_screen_pos: Vector2) -> void:
	var old_zoom = _target_zoom
	var new_zoom_val = clampf(_target_zoom.x * factor, min_zoom_level, max_zoom_level)
	_target_zoom = Vector2(new_zoom_val, new_zoom_val)
	
	if _target_zoom != old_zoom:
		# Pertahankan titik dunia di bawah kursor agar zoom terasa natural
		var viewport_center = get_viewport_rect().size * 0.5
		var mouse_offset_from_center = (mouse_screen_pos - viewport_center)
		
		var world_shift = mouse_offset_from_center * ((1.0 / old_zoom.x) - (1.0 / _target_zoom.x))
		position += world_shift
		_clamp_position()

func _clamp_position() -> void:
	if enable_limits:
		position.x = clampf(position.x, limit_left, limit_right)
		position.y = clampf(position.y, limit_top, limit_bottom)

# Fungsi API untuk fokus ke titik tertentu (misal: klik provinsi dari daftar)
func focus_on(target_position: Vector2, target_zoom_level: float = 1.0) -> void:
	position = target_position
	_target_zoom = Vector2(target_zoom_level, target_zoom_level)
	_clamp_position()
