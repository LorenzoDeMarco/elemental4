extends BaseDB

const FILEPATH_DB = "user://formulas.json"
const FILEPATH_PACKDB_DEFAULT = "res://packs/default/formulas.json"

func _init():
	filepath_db = FILEPATH_DB
	filepath_packdb_default = FILEPATH_PACKDB_DEFAULT
	remote_head_url = "http://localhost:3100/api/universe/formulas/count"
	remote_sync_url = "http://localhost:3100/api/universe/formulas"

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

func _sanitize(dto) -> Dictionary:
	dto.erase('publicBirthTime')
	return dto

func _prepare_for_save(db_elem):
	return Utility.formula_model_from_dto(db_elem).to_dto()
