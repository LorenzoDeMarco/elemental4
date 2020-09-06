extends Node

const FILEPATH_DB = "user://formulas.json"

var _db : Dictionary = {}

func formula_model_by_id(id: int) -> FormulaModel:
	populate_db()
	if _db.keys().has(id):
		return Utility.formula_model_from_dto(_db[id])
	else:
		return null

func _cmp_arrays(a: Array, b: Array) -> bool:
	if a.size() != b.size(): return false
	var a_sr = a.duplicate()
	a_sr.sort()
	for i in range(a_sr.size()):
		if a_sr[i] != b[i]: return false
	return true

func formula_by_inputs(input_ids: Array):
	populate_db()
	for val in _db.values():
		if _cmp_arrays(input_ids, val['inputs']):
			return Utility.formula_model_from_dto(val)
	return null

func formula_by_inputs_strict_order(input_ids: Array):
	populate_db()
	var ids = input_ids.duplicate()
	ids.sort()
	for val in _db.values():
		var v_ids = val['inputs'].duplicate()
		v_ids.sort()
		if _cmp_arrays(ids, v_ids):
			return Utility.formula_model_from_dto(val)
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
				for formula in data:
					_db[formula['id'] as int] = _sanitize(formula)
				print_debug(String(_db.size()) + " formulas loaded.")
				return
	_db = {}

func _sanitize(dto: Dictionary) -> Dictionary:
	dto.erase('publicBirthTime')
	return dto

func store_db():
	for k in _db.keys():
		_db[k] = Utility.formula_model_from_dto(_db[k]).to_dto()
	print_debug(String(_db.size()) + " formulas ready for saving.")
	var data = to_json(_db.values())
	var dbfile = File.new()
	if dbfile.open(FILEPATH_DB, File.WRITE) == OK:
		dbfile.store_string(data)
		dbfile.close()
		print_debug(String(_db.size()) + " formulas saved.")
	else:
		print_debug("Failed to save formulas to file.")
