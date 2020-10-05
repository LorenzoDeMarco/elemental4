extends Node

var _logged_in: bool = false
var _token: String = ""
var _sid: String = ""
var _user_remember: bool = true

var _profiles_manager: ProfilesManager = ProfilesManager.new()
var _profile: PlayerProfile = PlayerProfile.new()

const PATH_PROFILE = 'user://profiles/%s/profile.json'
const PATH_PROFILE_DEFAULT = 'res://settings/default_profile.json'

const SKEY_AUDIO_UISFX = 'audio.uisfx'
const SKEY_AUDIO_GAMESFX = 'audio.gamesfx'
const SKEY_AUDIO_MUSIC = 'audio.music'

const SKEY_PRIMARY_SERVER = 'net.primaryserver'

class PlayerProfile:
	
	export var id: String
	export var username: String
	export var pwh: String
	export var discovered_elements: Dictionary
	export var achievements: Array
	export var settings: Dictionary
	
	export var is_temporary: bool = false
	
	const ID_DEFAULT = "anonymous"
	
	const PKEY_USERNAME = "username"
	const PKEY_PWH = "pwh"
	const PKEY_ELEMS = "discovered_elements"
	const PKEY_ACHIEVEMENTS = "achievements"
	const PKEY_SETTINGS = "settings"
	
	signal username_changed(username)
	signal setting_changed(key, value)
	signal setting_removed(key)
	signal achievement_done(achievement_id, titleData, subtitleData)
	signal profile_loaded()
	signal profile_saved()
	
	func _init():
		wipe()
	
	func wipe():
		id = ID_DEFAULT
		username = ID_DEFAULT
		pwh = "password".sha256_text()
		discovered_elements = {}
		achievements = []
		settings = {}
	
	func load_by_id(id: String, silent: bool = false) -> bool:
		if OS.is_debug_build(): print_debug("Loading profile ID %s" % id)
		return load_from_file(PATH_PROFILE % id, id, silent)
	
	func load_from_file(path: String = PATH_PROFILE_DEFAULT, id: String = ID_DEFAULT, silent: bool = false) -> bool:
		var sf = File.new()
		if OS.is_debug_build(): print_debug("Loading profile file %s with ID %s" % [path, id])
		if sf.file_exists(path):
			if sf.open(path, File.READ) == OK:
				var data = parse_json(sf.get_as_text())
				sf.close()
				if typeof(data) == TYPE_DICTIONARY:
					self.id = id
					apply_raw(data, silent)
					return true
		return false
	
	func apply_raw(profile: Dictionary, silent: bool = false):
		if PKEY_USERNAME in profile:
			username = profile[PKEY_USERNAME]
			emit_signal("username_changed", username)
		if PKEY_PWH in profile:
			pwh = profile[PKEY_PWH]
		if PKEY_SETTINGS in profile:
			settings = profile[PKEY_SETTINGS]
		if PKEY_ELEMS in profile:
			discovered_elements = profile[PKEY_ELEMS]
		if PKEY_ACHIEVEMENTS in profile:
			achievements = profile[PKEY_ACHIEVEMENTS]
		if not silent:
			for sk in settings.keys():
				emit_signal("setting_changed", sk, settings[sk])
			emit_signal("profile_loaded")
	
	func save() -> bool:
		if is_temporary: return true
		var td : Dictionary = {}
		td[PKEY_USERNAME] = username
		td[PKEY_PWH] = pwh
		td[PKEY_SETTINGS] = settings
		td[PKEY_ELEMS] = discovered_elements
		td[PKEY_ACHIEVEMENTS] = achievements
		
		var sf = File.new()
		var p = PATH_PROFILE % id
		if sf.open(p, File.WRITE) == OK:
			sf.store_string(JSON.print(td))
			sf.close()
			emit_signal("profile_saved")
			return true
		return false
	
	func has_setting(key) -> bool:
		return settings.has(key)
	
	func get_setting(key):
		if OS.is_debug_build() and key == SKEY_PRIMARY_SERVER and Globals.OVERRIDE_LOCALSERVER:
			return "http://localhost:3100"
		return settings[key]
	
	func upsert_setting(key, value):
		settings[key] = value
		emit_signal("setting_changed", key, value)
	
	func delete_setting(key):
		settings.erase(key)
		emit_signal("setting_removed", key)

class ProfilesManager:
	var _profile_ids: Array = []
	
	func scan_profiles():
		_profile_ids = []
		var pd = Directory.new()
		if pd.open("user://profiles") != OK:
			pd.make_dir("user://profiles")
			return
		if pd.list_dir_begin() != OK: return
		var fname : String = pd.get_next()
		while fname != "":
			if pd.current_is_dir():
				_index_profile(fname)
			fname = pd.get_next()
	
	func _index_profile(dir_name: String):
		var pd = Directory.new()
		if pd.open("user://profiles/%s" % dir_name) != OK: return
		if not pd.file_exists("profile.json"): return
		if _profile_ids.has(dir_name): return
		_profile_ids.append(dir_name)
	
	func profile_id_exists(id: String) -> bool:
		return _profile_ids.has(id)
	
	func profile_username_exists(username: String) -> bool:
		return _profile_ids.has(username.sha256_text())
	
	func create_profile(username: String, autoload: bool = false, silent_load: bool = false) -> bool:
		var pd = Directory.new()
		var id = username.sha256_text()
		if pd.open("user://profiles") != OK: return false
		if pd.dir_exists(id): return false
		if pd.make_dir(id) != OK: return false
		if pd.copy(PATH_PROFILE_DEFAULT, PATH_PROFILE % id) != OK: return false
		var tmp: PlayerProfile = PlayerProfile.new()
		if not tmp.load_by_id(id): return false
		tmp.username = username
		if not tmp.save(): return false
		if autoload:
			return Player.get_profile().load_by_id(id, silent_load)
		return true
	
	func get_profile_ids() -> Array:
		return _profile_ids
	
	func get_profile_by_id(id: String) -> PlayerProfile:
		if not profile_id_exists(id): return null
		var tmp: PlayerProfile = PlayerProfile.new()
		if not tmp.load_by_id(id): return null
		return tmp
	
	func get_profile_by_username(username: String) -> PlayerProfile:
		return get_profile_by_id(username.sha256_text())

signal username_changed(username)
signal signin_state_changed(signed_in)
signal token_changed(token)
signal profile_loaded()
signal profile_saved()

func get_profiles_manager() -> ProfilesManager:
	return _profiles_manager

func get_profile() -> PlayerProfile:
	return _profile

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	_profiles_manager.scan_profiles()
	_profile.connect("achievement_done", self, "_on_achievement_done")
	_profile.connect("profile_loaded", self, "_on_profile_loaded")

func load_default(silent: bool = false):
	_profile.load_from_file(PATH_PROFILE_DEFAULT, PlayerProfile.ID_DEFAULT, silent)

func _on_profile_loaded():
	if OS.is_debug_build():
		print_debug("Loaded profile '%s'" % _profile.username)
	_profile.save()

func _on_achievement_done(_id, _data):
	if not _profile.save():
		Globals.add_notification_k(Globals.NK_PROFILE_SAVE_FAILED)

func is_logged_in() -> bool:
	return _logged_in

func _online_signin_response(response: HTTPUtil.Response):
	if response != null and response.response_code == HTTPClient.RESPONSE_OK:
		var json = JSON.parse(response.body.get_string_from_utf8())
		if json.error == OK and json.result is Dictionary:
			if not get_profiles_manager().profile_username_exists(json.result['username']):
				if not get_profiles_manager().create_profile(json.result['username'], true, true):
					emit_signal("signin_state_changed", false)
					return
			_profile.username = json.result['username']
			_profile.id = _profile.username.sha256_text()
			_token = json.result['token']
			_sid = json.result['sid']
			_logged_in = true
			emit_signal("signin_state_changed", _logged_in)
			emit_signal("username_changed", _profile.username)
			emit_signal("token_changed", _token)
			_profile.save()
			return
	load_default(true)
	_profile.username = ""
	_token = ""
	_sid = ""
	_logged_in = false
	emit_signal("signin_state_changed", false)
	emit_signal("username_changed", "")
	emit_signal("token_changed", "")

func online_signin(username: String, password_hb64: String, remember: bool = false) -> int:
	_user_remember = remember
	return HTTPUtil.request(funcref(self, "_online_signin_response"), \
		HTTPClient.METHOD_POST, Globals.get_primary_server() + "/api/auth/sessions", ["Content-Type: application/json"], \
		JSON.print({
		"username": username,
		"key": password_hb64
	}))

func online_signup(username: String, password_hb64: String, email: String) -> int:
	_user_remember = true
	return HTTPUtil.request(funcref(self, "_online_signin_response"), \
		HTTPClient.METHOD_POST, Globals.get_primary_server() + "/api/auth/sessions", ["Content-Type: application/json"], \
		JSON.print({
		"username": username,
		"key": password_hb64
	}))
