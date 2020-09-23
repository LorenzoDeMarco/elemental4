extends Node

var is_mobile: bool = false
var internet_access: bool = false

var _audio_uisfx_enabled : bool = true
var _audio_gamesfx_enabled : bool = true
var _audio_music_enabled : bool = true

var _scene_tween : Tween = null
var _notif_adder : FuncRef = null

var _primary_server : String = PRIMARY_SERVER_URL

export var primary_server : String = PRIMARY_SERVER_URL setget set_primary_server, get_primary_server

signal internet_status_changed(status)
signal primary_server_changed(url)

const OVERRIDE_DESKTOPALWAYS = true

const PRIMARY_SERVER_URL = "https://ledomsoft.com:3101"

const WINDOW_MIN_SIZE = Vector2(890, 680)

const VERSION = "0.2.1-alpha"
const IS_ALPHA : bool = true

const SKEY_AUDIO_UISFX = 'audio.uisfx'
const SKEY_AUDIO_GAMESFX = 'audio.gamesfx'
const SKEY_AUDIO_MUSIC = 'audio.music'

const SKEY_PRIMARY_SERVER = 'net.primaryserver'

const PATH_SETTINGS = 'user://profiles/%s/settings.json'
const PATH_SETTINGS_DEFAULT = 'res://settings/default.json'

const AUDIO_GAME_CLASSIC_POP = preload('res://sounds/game/classic_pop.ogg')
const AUDIO_UI_BUTTON_DOWN = preload('res://sounds/ui/button_down.wav')
const AUDIO_UI_BUTTON_HOVER = preload('res://sounds/ui/button_hover.wav')
const AUDIO_UI_GENERIC = preload('res://sounds/ui/generic.wav')
const AUDIO_UI_TOGGLE = preload('res://sounds/ui/toggle.wav')

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	OS.min_window_size = WINDOW_MIN_SIZE
	if not load_settings():
		if not load_default_settings():
			get_tree().quit(2)
	_spawn_audio_player("UISFX")
	_spawn_audio_player("GameSFX")
	_spawn_audio_player("Music")
	is_mobile = OS.has_feature("mobile")
	set_primary_server(PRIMARY_SERVER_URL)
	check_internet(true)

func check_internet(force_emit: bool = false):
	var status = Utility.internet_test()
	if force_emit or (status != internet_access):
		internet_access = status
		emit_signal("internet_status_changed", status)
	internet_access = status

func register_scene_tween(t: Tween):
	_scene_tween = t

func register_notification_adder(fn: FuncRef):
	_notif_adder = fn

func get_scene_tween() -> Tween:
	return _scene_tween

func add_notification(title: String, subtitle: String = "", icon: Texture = null):
	if _notif_adder != null:
		_notif_adder.call_func(title, subtitle, icon)

func _spawn_audio_player(bus: String):
	var ap = AudioStreamPlayer.new()
	ap.name = bus + "Player"
	ap.bus = bus
	add_child(ap)

func play_game_sfx(audio_res):
	var sfxp = get_game_sfx_player()
	if sfxp == null: return
	if sfxp.playing: sfxp.stop()
	sfxp.stream = audio_res
	sfxp.play()

func play_ui_sfx(audio_res):
	var sfxp = get_ui_sfx_player()
	if sfxp == null: return
	if sfxp.playing: sfxp.stop()
	sfxp.stream = audio_res
	sfxp.play()

func play_music(audio_res):
	var sfxp = get_music_player()
	if sfxp == null: return
	if sfxp.playing: sfxp.stop()
	sfxp.stream = audio_res
	sfxp.play()

func save_settings() -> bool:
	var td : Dictionary = {}
	td[SKEY_AUDIO_UISFX] = _audio_uisfx_enabled
	td[SKEY_AUDIO_GAMESFX] = _audio_gamesfx_enabled
	td[SKEY_AUDIO_MUSIC] = _audio_music_enabled
	td[SKEY_PRIMARY_SERVER] = _primary_server
	var sf = File.new()
	if sf.open(PATH_SETTINGS, File.WRITE) == OK:
		sf.store_string(JSON.print(td, "	"))
		sf.close()
		return true
	return false

func load_settings(path: String = PATH_SETTINGS) -> bool:
	var sf = File.new()
	if sf.file_exists(path):
		if sf.open(path, File.READ) == OK:
			var data = parse_json(sf.get_as_text())
			sf.close()
			if typeof(data) == TYPE_DICTIONARY:
				apply_settings_bulk(data)
				return true
	return false

func load_default_settings() -> bool:
	return load_settings(PATH_SETTINGS_DEFAULT) and save_settings()

func apply_settings_bulk(settings: Dictionary):
	if SKEY_AUDIO_UISFX in settings:
		_audio_uisfx_enabled = settings[SKEY_AUDIO_UISFX]
	if SKEY_AUDIO_GAMESFX in settings:
		_audio_gamesfx_enabled = settings[SKEY_AUDIO_GAMESFX]
	if SKEY_AUDIO_MUSIC in settings:
		_audio_music_enabled = settings[SKEY_AUDIO_MUSIC]
	if SKEY_PRIMARY_SERVER in settings:
		_primary_server = settings[SKEY_PRIMARY_SERVER]

func get_ui_sfx_player() -> AudioStreamPlayer:
	return ($UISFXPlayer as AudioStreamPlayer) if _audio_uisfx_enabled else null

func get_game_sfx_player() -> AudioStreamPlayer:
	return ($GameSFXPlayer as AudioStreamPlayer) if _audio_gamesfx_enabled else null

func get_music_player() -> AudioStreamPlayer:
	return ($MusicPlayer as AudioStreamPlayer) if _audio_music_enabled else null

func set_uisfx_enabled(enabled: bool):
	_audio_uisfx_enabled = enabled

func set_gamesfx_enabled(enabled: bool):
	_audio_gamesfx_enabled = enabled

func set_music_enabled(enabled: bool):
	_audio_music_enabled = enabled

func get_primary_server() -> String:
	return _primary_server

func set_primary_server(url: String):
	_primary_server = url
	emit_signal("primary_server_changed", url)
