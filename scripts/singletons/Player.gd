extends Node

const PATH_PROFILE = 'user://profile.json'
const PATH_PROFILE_DEFAULT = 'res://settings/profile.json'

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	if not load_profile():
		if not load_default_profile():
			get_tree().quit(2)

func save_profile() -> bool:
	var td : Dictionary = {}
	# td[KEY] = _local_value
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
	# _local_value = profile[KEY]
	pass
