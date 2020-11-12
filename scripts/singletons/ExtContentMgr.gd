extends Node

const UPD_DIR : String = "user://upd"
const DLC_DIR : String = "user://dlc"

const REMOTE_PKGSRC_URL : String = "/packages/"
const REMOTE_PKGIDX_URL : String = "index.json"

const LOCAL_UPD_DIR : String = "res://upd"
const LOCAL_UPD_KEY : String = 'updates'
const LOCAL_DLC_DIR : String = "res://dlc"
const LOCAL_DLC_KEY : String = 'dlcs'

var _index: Dictionary = {
	LOCAL_DLC_KEY: [],
	LOCAL_UPD_KEY: []
}

var remote_updates_index: Array = []

class SysPackManifest:
	
	const OVERRIDE_CLIENT_VERSION = 'client_version'
	
	export var uid: String = ''
	export var name: String = ''
	export var overrides: Dictionary = {}
	
	func apply_overrides():
		if overrides.has(OVERRIDE_CLIENT_VERSION):
			Globals.VERSION = overrides[OVERRIDE_CLIENT_VERSION]

func load_content():
	_index = {
		LOCAL_DLC_KEY: [],
		LOCAL_UPD_KEY: []
	}
	# Find Updates
	print("Loading updates...")
	if hotload_packs_recur(UPD_DIR) != OK:
		print_debug("hotload_packs_recur(UPD_DIR) failed")
	else:
		if not index_loaded_packs(LOCAL_UPD_KEY, LOCAL_UPD_DIR):
			print_debug("index_loaded_packs(LOCAL_UPD_KEY, LOCAL_UPD_DIR) failed")
	# Find DLCs
	print("Loading DLCs...")
	if hotload_packs_recur(DLC_DIR) != OK:
		print_debug("hotload_packs_recur(DLC_DIR) failed")
	else:
		if not index_loaded_packs(LOCAL_DLC_KEY, LOCAL_DLC_DIR):
			print_debug("index_loaded_packs(LOCAL_DLC_KEY, LOCAL_DLC_DIR) failed")

func check_updates(auto_install: bool = false):
	var url = Globals.get_primary_server() + REMOTE_PKGSRC_URL + REMOTE_PKGIDX_URL
	print("Fetching updates from %s ..." % url)
	HTTPUtil.request(funcref(self, '_check_updates_response'), HTTPClient.METHOD_GET, \
		url, [], '', false, auto_install)

signal update_check_completed(success, auto_install)
signal update_install_completed(success)

func _check_updates_response(response: HTTPUtil.Response, auto_install: bool):
	if response.response_code >= 200 and response.response_code < 400:
		var resp = parse_json(response.body.get_string_from_utf8())
		if typeof(resp) == TYPE_ARRAY:
			remote_updates_index = resp as Array
			emit_signal("update_check_completed", true, auto_install)
			if auto_install:
				download_updates()
		else:
			remote_updates_index = []
			emit_signal("update_check_completed", false, auto_install)
			emit_signal("update_install_completed", false)

var _updates_install_state: bool = false
var _updates_semaphore: Semaphore = Semaphore.new()
var _updates_download_mutex: Mutex = Mutex.new()

func download_updates():
	if remote_updates_index.size() == 0: return
	_updates_install_state = true
	# Sort newest->oldest
	remote_updates_index.invert()
	# Determine UID of the latest update.
	var latest: Dictionary = {}
	for record in remote_updates_index:
		if record.type == 'update-master':
			latest = record
			break
	if latest.size() == 0:
		# Nothing to download
		emit_signal("update_install_completed", true)
		return
	var to_download := [latest]
	# Dependencies
	_populate_record_dependencies(latest, to_download)
	if _updates_install_state:
		for upd in to_download:
			if not _updates_install_state:
				emit_signal("update_install_completed", false)
				return
			# Download update
			print("Need to download PUID=%s" % upd.puid)
			var dwnth := Thread.new()
			dwnth.start(self, '_download_update', upd)
			dwnth.wait_to_finish()
			# Wait on semaphore
			_updates_semaphore.wait()
			dwnth.free()
		# Install updates
		load_content()
	# Done
	emit_signal("update_install_completed", _updates_install_state)

func _populate_record_dependencies(record: Dictionary, list: Array):
	if not list.has(record):
		list.push_front(record)
	for dep in record.requires:
		if not _updates_install_state: return
		# Find record for the dependency
		var dep_record: Dictionary = {}
		for r in remote_updates_index:
			if r.puid == dep or r.uid == dep:
				dep_record = r
				break
		if dep_record.size() == 0:
			# Dependency not found
			_updates_install_state = false
			return
		else:
			# Add dependency and its dependencies recursively
			_populate_record_dependencies(dep_record, list)

func _on_update_downloaded(result, resp_code, headers, body, hr: HTTPRequest, record: Dictionary):
	_updates_download_mutex.unlock()
	#hr.queue_free()
	_updates_install_state = resp_code >= 200 and resp_code < 400
	if _updates_install_state:
		print("Downloaded update %s" % record.puid)
	else:
		print("Failed to download update %s - got HTTP status code %s" % [record.puid, str(resp_code)])
	_updates_semaphore.post()

func _download_update(record: Dictionary):
	# Type 
	var fn = Globals.get_primary_server() + REMOTE_PKGSRC_URL + record.puid
	# Compatibility check
	var pf := platforms_find_best(record.files.keys())
	if pf.empty():
		_updates_install_state = false
		_updates_semaphore.post()
		return
	fn += "/%s.pck" % record.files[pf]
	_updates_download_mutex.lock()
	# Compatible, downloading it
	print("Downloading update %s (%s)..." % [record.puid, fn])
	var hr := HTTPRequest.new()
	add_child(hr)
	# Create output file
	var tfn = "%s/%s.pck" % [UPD_DIR, record.installIndex]
	var tfn_f := File.new()
	if tfn_f.open(tfn, File.WRITE) != OK:
		_updates_download_mutex.unlock()
		_updates_install_state = false
		_updates_semaphore.post()
		return
	tfn_f.store_buffer(PoolByteArray([]))
	tfn_f.close()
	# Start download
	hr.download_file = tfn
	hr.connect("request_completed", ExtContentMgr, "_on_update_downloaded", [hr, record], CONNECT_ONESHOT)
	if hr.request(fn) != OK:
		_updates_install_state = false
		_updates_semaphore.post()
		return

func platforms_find_best(platforms: Array) -> String:
	var scores = {}
	for k in platforms:
		if typeof(k) != TYPE_STRING: continue
		var flags = k.split('-', false)
		var score: int = 0
		for f in flags:
			if OS.has_feature(f):
				score += 1
		if score == 0:
			continue
		else:
			scores[k] = score
	var max_score: int = 0
	var best: String = ''
	for pf in scores.keys():
		if scores[pf] > max_score:
			best = pf
			max_score = scores[pf]
	return best

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
	print("Loading %s ..." % filepath)
	return ProjectSettings.load_resource_pack(filepath)

func index_loaded_packs(categ_key: String, dirpath: String) -> bool:
	var dir: Directory = Directory.new()
	if dir.open(dirpath) != OK: return false
	if dir.list_dir_begin(true) != OK: return false
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with('.json'):
			index_loaded_pack(categ_key, dirpath + '/' + file_name)
		file_name = dir.get_next()
	return true

func index_loaded_pack(categ_key: String, manifest_path: String):
	var mf: File = File.new()
	if mf.open(manifest_path, File.READ) != OK: return
	var mc = mf.get_as_text()
	mf.close()
	var jpr = JSON.parse(mc)
	if jpr.error == OK:
		var manifest: Dictionary = jpr.result 
		_index[categ_key].append(parse_manifest(manifest))

func parse_manifest(raw: Dictionary) -> SysPackManifest:
	var tmp: SysPackManifest = SysPackManifest.new()
	if raw.has('uid'):
		tmp.uid = raw['uid']
	if raw.has('name'):
		tmp.name = raw['name']
	if raw.has('overrides'):
		tmp.overrides = raw['overrides']
	tmp.apply_overrides()
	return tmp

func get_index_records(categ_key: String) -> Array:
	return _index[categ_key] if _index.has(categ_key) else null
