extends Reference
class_name ElementModel

const ID_NONE : int = -1

var _id : int = -1
var _name : String
var _mark : String
var _birth : int = -1
var _original_equation_id : int = -1
var _color : Color

export var id : int setget ,get_id
export var name : String setget ,get_name
export var mark : String setget ,get_mark
export var color : Color setget ,get_color

func get_id() -> int:
	return _id

func get_name() -> String:
	return _name

func get_mark() -> String:
	return _mark

func get_color() -> Color:
	return _color

func _init(id: int, name: String, color: Color = Color.white, mark: String = ""):
	_id = ID_NONE if id < ID_NONE else id
	_name = name
	_color = color
	_mark = mark

func to_dto() -> Dictionary:
	var dto : Dictionary = {}
	if _id > -1:
		dto['id'] = _id
	dto['name'] = _name
	dto['color'] = "#" + _color.to_html(false)
	dto['mark'] = _mark
	if _birth > -1:
		dto['birthTime'] = _birth
	if _original_equation_id > -1:
		dto['originalEquation'] = _original_equation_id
	return dto
