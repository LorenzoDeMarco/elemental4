extends Node

var _username: String = ""
var _logged_in: bool = false
var _token: String = ""
var _sid: String = ""
var _user_remember: bool = true
var _discovered_elements: Dictionary = {}
var _achievements: Array = []

const SKEY_TOKEN = "token"
const SKEY_ELEMS = "discovered_elements"
const SKEY_ACHIEVEMENTS = "achievements"

const PATH_PROFILE = 'user://profile.json'
const PATH_PROFILE_DEFAULT = 'res://settings/profile.json'

signal username_changed(username)
signal signin_state_changed(signed_in)
signal token_changed(token)

signal achievement_done(achievement_id, data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if not (load_profile() and save_profile()):
		if not load_default_profile():
			get_tree().quit(2)
	connect("achievement_done", self, "_on_achievement_done")

func _on_achievement_done(_id, _data):
	if not save_profile():
		GlobalSettings.add_notification("Failed to save profile", "Please make sure your storage is writable!")

func save_profile() -> bool:
	if not _user_remember: return true
	var td : Dictionary = {}
	td[SKEY_TOKEN] = _token
	td[SKEY_ELEMS] = _discovered_elements
	td[SKEY_ACHIEVEMENTS] = _achievements
	
	var sf = File.new()
	if sf.open(PATH_PROFILE, File.WRITE) == OK:
		sf.store_string(JSON.print(td))
		sf.close()
		return true
	return false

func load_profile(path: String = PATH_PROFILE) -> bool:
	var sf = File.new()
	if sf.file_exists(path):
		if sf.open(path, File.READ) == OK:
			var data = parse_json(sf.get_as_text())
			sf.close()
			if typeof(data) == TYPE_DICTIONARY:
				apply_profile_bulk(data)
				return true
	return false

func load_default_profile() -> bool:
	return load_profile(PATH_PROFILE_DEFAULT) and save_profile()

func apply_profile_bulk(profile: Dictionary):
	if SKEY_ELEMS in profile:
		_discovered_elements = profile[SKEY_ELEMS]
	if SKEY_ACHIEVEMENTS in profile:
		_achievements = profile[SKEY_ACHIEVEMENTS]
	if SKEY_TOKEN in profile: 
		_token = profile[SKEY_TOKEN]
		emit_signal("token_changed", _token)
	pass

func _online_signin_response(response: HTTPUtil.Response):
	if response != null and response.response_code == HTTPClient.RESPONSE_OK:
		var json = JSON.parse(response.body.get_string_from_utf8())
		if json.error == OK and json.result is Dictionary:
			_username = json.result['username']
			_token = json.result['token']
			_sid = json.result['sid']
			_logged_in = true
		else:
			_username = ""
			_token = ""
			_sid = ""
			_logged_in = false
	else:
		_username = ""
		_token = ""
		_sid = ""
		_logged_in = false
	emit_signal("signin_state_changed", _logged_in)
	emit_signal("username_changed", _username)
	emit_signal("token_changed", _token)
	save_profile()

func online_signin(username: String, password_hb64: String, remember: bool = false) -> int:
	_user_remember = remember
	return HTTPUtil.request(funcref(self, "_online_signin_response"), \
		HTTPClient.METHOD_POST, GlobalSettings.PRIMARY_SERVER_URL + "/api/auth/sessions", ["Content-Type: application/json"], \
		JSON.print({
		"username": username,
		"key": password_hb64
	}))

func mixed_element(result: ElementModel):
	var curr_pack = ElementDB.get_pack_name()
	if not _discovered_elements.has(curr_pack):
		_discovered_elements[curr_pack] = []
		emit_signal("achievement_done", "universe:first_mix_of_pack", [result, curr_pack])
	if not result.id in _discovered_elements[curr_pack]:
		_discovered_elements[curr_pack].append(result.id)
		emit_signal("achievement_done", "universe:mix_new_element", result)
