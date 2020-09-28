extends Reference
class_name ElementModel

const ID_NONE : int = -1

var _id : int = -1
var _picture_id : int = -1
var _name : String
var _mark : String
var _birth : int = -1
var _original_equation_id : int = -1
var _color : Color

var _picture_cache : Texture = null

export var id : int setget ,get_id
export var picture_id : int setget ,get_picture_id
export var name : String setget ,get_name
export var mark : String setget ,get_mark
export var color : Color setget ,get_color

signal picture_cached(picture)

func get_id() -> int:
	return _id

func get_name() -> String:
	return _name

func get_mark() -> String:
	return _mark

func get_color() -> Color:
	return _color

func get_picture_id() -> int:
	return _picture_id

func _init(id: int, name: String, color: Color = Color.white, mark: String = "", picture_id: int = -1):
	_id = ID_NONE if id < ID_NONE else id
	_name = name
	_color = color
	_mark = mark
	_picture_id = picture_id

func to_dto() -> Dictionary:
	var dto : Dictionary = {}
	if _id > -1:
		dto['id'] = _id
	dto['name'] = _name
	dto['color'] = "#" + _color.to_html(false)
	dto['mark'] = _mark
	dto['picture_id'] = _picture_id
	if _birth > -1:
		dto['birthTime'] = _birth
	if _original_equation_id > -1:
		dto['originalEquation'] = _original_equation_id
	return dto

func _on_picture(pack: String, id: String, success: bool):
	if success:
		_picture_cache = ElementPictureDB.get_picture(pack, id)
		emit_signal("picture_cached", _picture_cache)
	else:
		_picture_cache = null

func is_picture_cached():
	return _picture_cache != null

func resolve_picture(discard_cache: bool = false):
	if _picture_id < 0: return
	if discard_cache: _picture_cache = null
	elif _picture_cache != null: return
	ElementPictureDB.provide_picture(ElementDB.get_pack_name(), String(_picture_id), \
		"http://", self, "_on_picture")
