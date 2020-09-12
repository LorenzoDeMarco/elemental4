extends Node

var is_mobile: bool = false

var _audio_uisfx_enabled : bool = true
var _audio_gamesfx_enabled : bool = true
var _audio_music_enabled : bool = true

const SKEY_AUDIO_UISFX = 'audio.uisfx'
const SKEY_AUDIO_GAMESFX = 'audio.gamesfx'
const SKEY_AUDIO_MUSIC = 'audio.music'

const PATH_SETTINGS = 'user://settings.json'
const PATH_SETTINGS_DEFAULT = 'res://settings/default.json'

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	if not load_settings():
		if not load_default_settings():
			get_tree().quit(2)
	_spawn_audio_player("UISFX")
	_spawn_audio_player("GameSFX")
	_spawn_audio_player("Music")
	is_mobile = OS.has_feature("mobile")

func _spawn_audio_player(bus: String):
	var ap = AudioStreamPlayer.new()
	ap.name = bus + "Player"
	ap.bus = bus
	add_child(ap)

func save_settings() -> bool:
	var td : Dictionary = {}
	td[SKEY_AUDIO_UISFX] = _audio_uisfx_enabled
	td[SKEY_AUDIO_GAMESFX] = _audio_gamesfx_enabled
	td[SKEY_AUDIO_MUSIC] = _audio_music_enabled
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
	_audio_uisfx_enabled = settings[SKEY_AUDIO_UISFX]
	_audio_gamesfx_enabled = settings[SKEY_AUDIO_GAMESFX]
	_audio_music_enabled = settings[SKEY_AUDIO_MUSIC]

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
