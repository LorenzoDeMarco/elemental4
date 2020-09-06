extends Draggable
class_name Element

var _model : ElementModel = null
var _element_id : int
var _accept_drop : bool = true

export var element_id : int setget set_element_id, get_element_id
export var element_color : Color setget ,get_element_color
var element_model : ElementModel setget ,get_element_model

func set_element_id(value: int):
	_element_id = value
	update_element_display()

func get_element_id() -> int:
	return _element_id

func get_element_color() -> Color:
	return $ElemSquare.modulate

func get_element_model() -> ElementModel:
	return _model

func accept_drop(enable: bool):
	_accept_drop = enable

func accepts_drop() -> bool:
	return _accept_drop

# Called when the node enters the scene tree for the first time.
func _ready():
	update_element_display()

func update_element_display():
	# Fetch model
	_model = ElementDB.element_model_by_id(_element_id)
	if _model == null:
		return
	# Name
	$ElemName.text = _model.name
	# Colors
	$ElemSquare.modulate = _model.color
	$ElemName.add_color_override("font_color", Color.from_hsv(0, 0, 0 if 1 - _model.color.v < 0.2 else 1, 1))

func _on_gui_input(event):
	handle_gui_input(event)
