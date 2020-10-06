extends Node

const UPD_DIR : String = "user://upd"
const DLC_DIR : String = "user://dlc"

func _ready():
	# Find Updates
	print("Loading updates...")
	if hotload_packs_recur(UPD_DIR) != OK:
		print_debug("hotload_packs_recur(UPD_DIR) failed")
	# Find DLCs
	print("Loading DLCs...")
	if hotload_packs_recur(DLC_DIR) != OK:
		print_debug("hotload_packs_recur(DLC_DIR) failed")

func hotload_packs_recur(dirpath: String) -> int:
	var dir : Directory = Directory.new()
	var err = OK
	if not dir.dir_exists(dirpath):
		err = dir.make_dir(dirpath)
		if err != OK:
			return err
	err = dir.open(dirpath)
	if err == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			print("Found: " + file_name)
			if dir.current_is_dir():
				hotload_packs_recur(dirpath + '/' + file_name)
			else:
				hotload_pack(dirpath + '/' + file_name)
			file_name = dir.get_next()
		return OK
	else:
		return err

func hotload_pack(filepath: String) -> bool:
	return ProjectSettings.load_resource_pack(filepath)
