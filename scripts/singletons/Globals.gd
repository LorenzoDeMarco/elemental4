extends Node

var is_mobile: bool = false
var internet_access: bool = false

var _audio_uisfx_enabled : bool = true
var _audio_gamesfx_enabled : bool = true
var _audio_music_enabled : bool = true

var _scene_tween : Tween = null
var _notif_adder : FuncRef = null

var _notif_models : Dictionary = {}
var _achv_models : Dictionary = {}

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
const PATH_SETTINGS_DEFAULT = 'res://settings/default_profile.json'

const AUDIO_GAME_CLASSIC_POP = preload('res://sounds/game/classic_pop.ogg')
const AUDIO_UI_BUTTON_DOWN = preload('res://sounds/ui/button_down.wav')
const AUDIO_UI_BUTTON_HOVER = preload('res://sounds/ui/button_hover.wav')
const AUDIO_UI_GENERIC = preload('res://sounds/ui/generic.wav')
const AUDIO_UI_TOGGLE = preload('res://sounds/ui/toggle.wav')

const NK_PROFILE_SAVE_FAILED = "profile_save_failed"

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	OS.min_window_size = WINDOW_MIN_SIZE
	_load_achievements()
	_load_notifications()
	_spawn_audio_player("UISFX")
	_spawn_audio_player("GameSFX")
	_spawn_audio_player("Music")
	is_mobile = OS.has_feature("mobile")
	check_internet(true)

func _load_achievements():
	var nmf = File.new()
	if nmf.open("res://settings/achievements.json") != OK: return
	var nmr = JSON.parse(nmf.get_as_text())
	nmf.close()
	if nmr.error != OK: return
	for elem in (nmr.result as Array):
		_achv_models[elem['key']] = elem

func _load_notifications():
	var nmf = File.new()
	if nmf.open("res://settings/notifications.json") != OK: return
	var nmr = JSON.parse(nmf.get_as_text())
	nmf.close()
	if nmr.error != OK: return
	for elem in (nmr.result as Array):
		_notif_models[elem['key']] = elem

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
		_notif_adder.call_func("", title, subtitle, icon)

func add_notification_k(key: String):
	if (_notif_adder != null) and (key in _notif_models):
		var mdl = _notif_models[key]
		var title: String = mdl['title'] if 'title' in mdl else ""
		var subtitle: String = mdl['subtitle'] if 'subtitle' in mdl else ""
		var icon: Texture = load(mdl['icon']) if 'icon' in mdl else null
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

func get_ui_sfx_player() -> AudioStreamPlayer:
	return ($UISFXPlayer as AudioStreamPlayer) if Player.get_profile().get_setting(SKEY_AUDIO_UISFX) else null

func get_game_sfx_player() -> AudioStreamPlayer:
	return ($GameSFXPlayer as AudioStreamPlayer) if Player.get_profile().get_setting(SKEY_AUDIO_GAMESFX) else null

func get_music_player() -> AudioStreamPlayer:
	return ($MusicPlayer as AudioStreamPlayer) if Player.get_profile().get_setting(SKEY_AUDIO_MUSIC) else null

func set_uisfx_enabled(enabled: bool):
	Player.get_profile().upsert_setting(SKEY_AUDIO_UISFX, enabled)

func set_gamesfx_enabled(enabled: bool):
	Player.get_profile().upsert_setting(SKEY_AUDIO_GAMESFX, enabled)

func set_music_enabled(enabled: bool):
	Player.get_profile().upsert_setting(SKEY_AUDIO_MUSIC, enabled)

func get_primary_server() -> String:
	return Player.get_profile().get_setting(SKEY_PRIMARY_SERVER)

func set_primary_server(url: String):
	Player.get_profile().upsert_setting(SKEY_PRIMARY_SERVER, url)
	emit_signal("primary_server_changed", url)
