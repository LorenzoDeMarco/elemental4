extends Object
class_name ElementModel

const ID_NONE : int = -1

var _id : int
var _name : String
var _mark : String
var _birth : int
var _original_equation_id : int
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
	dto['id'] = _id
	dto['name'] = _name
	dto['color'] = "#" + _color.to_html(false)
	dto['mark'] = _mark
	dto['birthTime'] = _birth
	dto['originalEquation'] = _original_equation_id
	return dto
