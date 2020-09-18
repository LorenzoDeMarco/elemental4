extends BaseDB

const FILEPATH_DB = "user://elems.json"
const FILEPATH_PACKDB_DEFAULT = "res://packs/default/elems.json"

func _init():
	filepath_db = FILEPATH_DB
	filepath_packdb_default = FILEPATH_PACKDB_DEFAULT
	remote_head_url = GlobalSettings.PRIMARY_SERVER_URL + "/api/universe/elements/count"
	remote_sync_url = GlobalSettings.PRIMARY_SERVER_URL + "/api/universe/elements"

func element_model_by_id(id: int) -> ElementModel:
	populate_db()
	if _db.keys().has(id):
		return Utility.element_model_from_dto(_db[id])
	else:
		return null

func element_model_by_index(index: int) -> ElementModel:
	populate_db()
	if index < _db.size():
		return Utility.element_model_from_dto(_db.values()[index])
	else:
		return null

func _sanitize(dto: Dictionary) -> Dictionary:
	dto['id'] = int(dto['id'])
	dto.erase('owners')
	dto.erase('publicBirthTime')
	dto.erase('nameChanges')
	dto.erase('prevalence')
	dto.erase('usefulness')
	return dto

func _prepare_for_save(db_elem):
	return Utility.element_model_from_dto(db_elem).to_dto()
