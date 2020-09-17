extends Node

var _username: String = ""
var _logged_in: bool = false
var _token: String = ""
var _sid: String = ""

const SKEY_TOKEN = "token"

const PATH_PROFILE = 'user://profile.json'
const PATH_PROFILE_DEFAULT = 'res://settings/profile.json'

signal username_changed(username)
signal signin_state_changed(signed_in)
signal token_changed(token)

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if not load_profile():
		if not load_default_profile():
			get_tree().quit(2)

func save_profile() -> bool:
	var td : Dictionary = {}
	td[SKEY_TOKEN] = _token
	
	var sf = File.new()
	if sf.open(PATH_PROFILE, File.WRITE) == OK:
		sf.store_string(JSON.print(td, "	"))
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

func online_signin(username: String, password_hb64: String) -> int:
	return HTTPUtil.request(funcref(self, "_online_signin_response"), \
		HTTPClient.METHOD_POST, "http://localhost:3100/api/auth/sessions", ["Content-Type: application/json"], \
		JSON.print({
		"username": username,
		"key": password_hb64
	}))
