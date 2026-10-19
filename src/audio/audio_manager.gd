# audio_manager.gd
# Modul singleton pengelola tata suara dan efek audio atmosfer medan tempur (Sound FX).
# Menggunakan sintesis audio prosedural AudioStreamWAV 16-bit mandiri tanpa dependensi file eksternal.
extends Node

var _player_ui: AudioStreamPlayer
var _player_combat: AudioStreamPlayer
var _player_siren: AudioStreamPlayer
var _player_move: AudioStreamPlayer

var snd_blip: AudioStreamWAV
var snd_move: AudioStreamWAV
var snd_cannon: AudioStreamWAV
var snd_gunfire: AudioStreamWAV
var snd_siren: AudioStreamWAV

const MIX_RATE: int = 22050

func _ready() -> void:
	_init_audio_streams()
	_create_audio_players()
	_connect_event_bus()
	print("[AUDIO] AudioManager: Tata suara taktis & atmosfer medan tempur terpasang.")

func _create_audio_players() -> void:
	_player_ui = AudioStreamPlayer.new()
	_player_ui.name = "PlayerUI"
	_player_ui.volume_db = -8.0
	add_child(_player_ui)
	
	_player_move = AudioStreamPlayer.new()
	_player_move.name = "PlayerMove"
	_player_move.volume_db = -6.0
	add_child(_player_move)
	
	_player_combat = AudioStreamPlayer.new()
	_player_combat.name = "PlayerCombat"
	_player_combat.volume_db = -4.0
	add_child(_player_combat)
	
	_player_siren = AudioStreamPlayer.new()
	_player_siren.name = "PlayerSiren"
	_player_siren.volume_db = -5.0
	add_child(_player_siren)

func _init_audio_streams() -> void:
	snd_blip = _synthesize_ui_blip()
	snd_move = _synthesize_order_move()
	snd_cannon = _synthesize_cannon()
	snd_gunfire = _synthesize_gunfire()
	snd_siren = _synthesize_siren()

func _connect_event_bus() -> void:
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus != null:
		event_bus.province_clicked.connect(func(_p): play_ui_click())
		event_bus.unit_selected.connect(func(_u): play_ui_click())
		event_bus.unit_movement_started.connect(func(_u, _f, _t): play_order_move())
		event_bus.combat_started.connect(func(_p, _a, _d): 
			play_cannon_fire()
		)
		event_bus.province_owner_changed.connect(_on_province_owner_changed)

func _on_province_owner_changed(_prov, old_owner, new_owner) -> void:
	var player_country = get_tree().root.find_child("Main", true, false)
	# Jika provinsi pemain direbut musuh, bunyikan sirine peringatan perang!
	if old_owner != null and new_owner != null:
		if "player_country" in old_owner:
			play_siren()
		else:
			play_order_move()

# ----------------- FUNGSI PEMUTAR SUARA PUBLIK -----------------

func play_ui_click() -> void:
	if _player_ui != null and snd_blip != null:
		_player_ui.stream = snd_blip
		_player_ui.play()

func play_order_move() -> void:
	if _player_move != null and snd_move != null:
		_player_move.stream = snd_move
		_player_move.play()

func play_cannon_fire() -> void:
	if _player_combat != null and snd_cannon != null:
		_player_combat.stream = snd_cannon
		_player_combat.play()

func play_gunfire() -> void:
	if _player_combat != null and snd_gunfire != null:
		_player_combat.stream = snd_gunfire
		_player_combat.play()

func play_siren() -> void:
	if _player_siren != null and snd_siren != null:
		_player_siren.stream = snd_siren
		_player_siren.play()

# ----------------- GENERATOR SINTESIS AUDIO PROSEDURAL -----------------

func _synthesize_ui_blip() -> AudioStreamWAV:
	# Suara klik taktis UI komando militer (tactical blip / radio squelch)
	var duration = 0.05
	var count = int(MIX_RATE * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	
	for i in range(count):
		var t = float(i) / float(MIX_RATE)
		var env = 1.0 - (float(i) / float(count))
		var wave = sin(TAU * 920.0 * t) * 0.8 + (randf() * 2.0 - 1.0) * 0.2
		var sample = int(wave * env * 14000.0)
		bytes.encode_s16(i * 2, sample)
	
	return _create_wav(bytes)

func _synthesize_order_move() -> AudioStreamWAV:
	# Nada respon konfirmasi komunikasi radio (roger beep 2-tone)
	var duration = 0.12
	var count = int(MIX_RATE * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	var half = count / 2
	
	for i in range(count):
		var t = float(i) / float(MIX_RATE)
		var f = 640.0 if i < half else 960.0
		var env = 1.0 - (float(i % half) / float(half)) * 0.3
		var sample = int(sin(TAU * f * t) * env * 12000.0)
		bytes.encode_s16(i * 2, sample)
	
	return _create_wav(bytes)

func _synthesize_cannon() -> AudioStreamWAV:
	# Dentuman meriam tank dan artileri medan yang dalam dengan decay gema
	var duration = 0.45
	var count = int(MIX_RATE * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	
	for i in range(count):
		var t = float(i) / float(MIX_RATE)
		var env = exp(-t * 8.5)
		var freq = 150.0 * (1.0 - t / duration) + 32.0
		var noise = (randf() * 2.0 - 1.0) * 0.35
		var wave = (sin(TAU * freq * t) * 0.65 + noise) * env
		var sample = int(clampf(wave, -1.0, 1.0) * 22000.0)
		bytes.encode_s16(i * 2, sample)
	
	return _create_wav(bytes)

func _synthesize_gunfire() -> AudioStreamWAV:
	# Berondongan tembakan senapan serbu otomatis (burst firing)
	var duration = 0.26
	var count = int(MIX_RATE * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	
	for i in range(count):
		var t = float(i) / float(MIX_RATE)
		var pulse = fmod(t * 18.0, 1.0) # 3-4 letusan cepat
		var env = exp(-pulse * 9.0)
		var noise = (randf() * 2.0 - 1.0)
		var sample = int(noise * env * 15000.0)
		bytes.encode_s16(i * 2, sample)
	
	return _create_wav(bytes)

func _synthesize_siren() -> AudioStreamWAV:
	# Sirine peringatan perang (air raid / battle alarm klaxon)
	var duration = 1.2
	var count = int(MIX_RATE * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	
	for i in range(count):
		var t = float(i) / float(MIX_RATE)
		# Frekuensi berayun antara 480 Hz dan 760 Hz
		var f = 560.0 + 180.0 * sin(TAU * 2.5 * t)
		var wave = sin(TAU * f * t)
		var sample = int(wave * 16000.0)
		bytes.encode_s16(i * 2, sample)
	
	return _create_wav(bytes)

func _create_wav(bytes: PackedByteArray) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
