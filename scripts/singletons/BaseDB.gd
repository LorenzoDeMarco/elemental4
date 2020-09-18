extends Node
class_name BaseDB

var filepath_db = "user://elems.json"
var filepath_packdb_default = "res://packs/default/elems.json"
var remote_head_url = "http://localhost:3100/api/universe/elements/count"
var remote_sync_url = "http://localhost:3100/api/universe/elements"

signal db_sync_progress(added_count)
signal db_sync_done()
signal db_sync_size(size)

var _db : Dictionary = {
}

func _ready():
	connect("db_sync_done", self, "_on_db_synced", [], CONNECT_DEFERRED)

func _on_db_synced():
	if _db.size() > 0:
		store_db()

func get_db_size():
	return _db.size()

func get_db_first_key() -> int:
	return _db.keys()[0] if _db.size() > 0 else -INF

func get_db_max_key() -> int:
	return _db.keys().max() if _db.size() > 0 else -1

func populate_db():
	if _db.size() <= 1:
		load_local_db()
		if Utility.internet_test():
			load_remote_db()
		emit_signal("db_sync_done")
			

func load_remote_db():
	HTTPUtil.request(funcref(self, "_remote_data_head"), HTTPClient.METHOD_GET, remote_head_url, \
		["Content-Type: application/json"], JSON.print({
		"pack_id": "default",
		"last_known_id": get_db_max_key()
	}))

func _remote_data_head(resp: HTTPUtil.Response):
	if resp.response_code == HTTPClient.RESPONSE_OK:
		var size: int = int(resp.body.get_string_from_utf8())
		if size == 0:
			emit_signal("db_sync_size", 0)
			emit_signal("db_sync_done")
			return
		emit_signal("db_sync_size", size)
		HTTPUtil.request(funcref(self, "_remote_data"), HTTPClient.METHOD_GET, remote_sync_url, \
			["Content-Type: application/json"], JSON.print({
			"pack_id": "default",
			"last_known_id": get_db_max_key()
		}))
	else:
		emit_signal("db_sync_done")

func _remote_data(resp: HTTPUtil.Response):
	if resp.response_code == HTTPClient.RESPONSE_OK:
		var json = JSON.parse(resp.body.get_string_from_utf8())
		if json.error == OK:
			_load_data(json.result)
			if typeof(json.result) == TYPE_ARRAY and json.result.size() > 0:
				emit_signal("db_sync_progress", json.result.size())
				load_remote_db()
				return
			else:
				emit_signal("db_sync_done")

func load_local_db() -> int:
	var maxid: int = -1
	if not GlobalSettings.is_mobile:
		maxid = _load_file(filepath_db)
		if maxid > -1: return maxid
	var result = _load_file(filepath_packdb_default)
	emit_signal("db_sync_done")
	return result

func _load_data(data):
	var max_known_id: int = -1
	if typeof(data) == TYPE_ARRAY:
		for elem in data:
			var id: int = elem['id'] as int
			_db[id] = _sanitize(elem)
			if id > max_known_id:
				max_known_id = id
		return max_known_id
	return -1

func _load_file(path: String) -> int:
	var dbfile = File.new()
	if dbfile.file_exists(path):
		if dbfile.open(path, File.READ) == OK:
			var data = parse_json(dbfile.get_as_text())
			dbfile.close()
			return _load_data(data)
	_db = {}
	return -1

func store_db():
	for k in _db.keys():
		_db[k] = _prepare_for_save(_db[k])
	var data = to_json(_db.values())
	var dbfile = File.new()
	if dbfile.open(filepath_db, File.WRITE) == OK:
		dbfile.store_string(data)
		dbfile.close()

func _sanitize(dto: Dictionary):
	pass

func _prepare_for_save(db_elem):
	pass
