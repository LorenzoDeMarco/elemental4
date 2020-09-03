extends Node

const FILEPATH_DB = "user://elems.json"

var _db : Dictionary = {
	ElementModel.ID_NONE: { 'id': ElementModel.ID_NONE, 'name': '', 'color': Color.transparent.to_html(false) }
}

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_db()

func element_model_by_id(id: int) -> ElementModel:
	populate_db()
	if _db.keys().has(id):
		return ElementModel.new(ElementModel.ID_NONE, "").from_dto(_db[id])
	else:
		return null

func populate_db():
	if _db.size() <= 1:
		load_local_db()

func load_local_db():
	var dbfile = File.new()
	if dbfile.file_exists(FILEPATH_DB):
		if dbfile.open(FILEPATH_DB, File.READ) == OK:
			var data = parse_json(dbfile.get_as_text())
			dbfile.close()
			if typeof(data) == TYPE_ARRAY:
				for elem in data:
					_db[elem['id'] as int] = _sanitize(elem)
				print_debug(String(_db.size()) + " elements loaded.")
				return
	_db = {}

func _sanitize(dto: Dictionary) -> Dictionary:
	dto['id'] = int(dto['id'])
	dto.erase('owners')
	dto.erase('publicBirthTime')
	dto.erase('nameChanges')
	dto.erase('prevalence')
	dto.erase('usefulness')
	return dto

func store_db():
	var neg = _db[-1]
	_db.erase(-1)
	for k in _db.keys():
		_db[k] = ElementModel.new(ElementModel.ID_NONE, "").from_dto(_db[k]).to_dto()
	print_debug(String(_db.size()) + " elements ready for saving.")
	var data = to_json(_db.values())
	var dbfile = File.new()
	if dbfile.open(FILEPATH_DB, File.WRITE) == OK:
		dbfile.store_string(data)
		dbfile.close()
		print_debug(String(_db.size()) + " elements saved.")
	else:
		print_debug("Failed to save elements to file.")
	_db[-1] = neg
