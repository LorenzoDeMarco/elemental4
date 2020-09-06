extends Object
class_name FormulaModel

var _id : int
var _input_ids : Array
var _output_id : int
var _birth : int
var _votes : int
var _consensus : int
var _new_element : bool

export var id : int setget ,get_id
export var inputs : Array setget ,get_inputs
export var output_id : int setget ,get_output_id
export var birth : int setget ,get_birth
export var votes : int setget ,get_votes
export var consensus : int setget ,get_consensus
export var new_element : bool setget ,is_new_element

func get_id() -> int:
	return _id

func get_inputs() -> Array:
	return _input_ids

func get_output_id() -> int:
	return _output_id

func get_birth() -> int:
	return _birth

func get_votes() -> int:
	return _votes

func get_consensus() -> int:
	return _consensus

func is_new_element() -> bool:
	return _new_element

func _init(id: int, input_ids: Array, output_id: int, new_element: bool, birth: int = OS.get_unix_time(), votes: int = 0, consensus: int = 0):
	_id = id
	_input_ids = input_ids
	_output_id = output_id
	_new_element = new_element
	_birth = birth
	_votes = votes
	_consensus = consensus

func to_dto() -> Dictionary:
	var dto : Dictionary = {}
	dto['id'] = _id
	dto['inputs'] = _input_ids
	dto['output'] = _output_id
	dto['birth'] = _birth
	dto['votes'] = _votes
	dto['consensus'] = _consensus
	dto['isNewElement'] = _new_element
	return dto
