extends Draggable
class_name Element

var _model : ElementModel = null
var _element_id : int
var _accept_drop : bool = true
var _container: Control = null
var _container_pos: Vector2 = Vector2.ZERO

var _old_cpos: Vector2 = Vector2(-INF, -INF)

onready var _tween = GlobalSettings.get_scene_tween()

export var animate: bool = true

export var element_id : int setget set_element_id, get_element_id
export var element_color : Color setget ,get_element_color
var element_model : ElementModel setget ,get_element_model

var model_override : ElementModel = null

signal show_info(model)
signal hide_info()

var anim_state : int = -1

var _sre_connected: bool = false

func get_parent_container() -> Control:
	return _container

func set_parent_container(container: Control):
	if container != null:
		_container = container
		_container_pos = rect_global_position - container.rect_global_position
		if not _sre_connected:
			get_tree().connect("screen_resized", self, "_align_with_parent")
			_sre_connected = true
	else:
		if _sre_connected:
			get_tree().disconnect("screen_resized", self, "_align_with_parent")
			_sre_connected = false
		_container = null
		_container_pos = Vector2.ZERO

func _align_with_parent():
	set_global_position(_container.rect_global_position + _container_pos)

func _show_info():
	emit_signal("show_info", _model)

func _hide_info():
	emit_signal("hide_info")
	
func being_dragged(_a):
	play_pop_hi(_a)
	emit_signal("show_info", _model)

func play_pop_hi(_a):
	if animate and anim_state == 0:
		_tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1.25, 1.25), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_tween.start()
		anim_state = 1

func play_pop_lo(_a):
	if animate and anim_state == 1:
		_tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1, 1), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_tween.start()
		anim_state = 0

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
	connect("begin_drag", self, "being_dragged")
	connect("end_drag", self, "play_pop_lo")
	update_element_display()
	if animate and anim_state == -1:
		_tween.interpolate_property(self, "rect_scale", Vector2(0, 0), Vector2(1, 1), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		_tween.start()
		anim_state = 0

func update_element_display():
	# Fetch model
	_model = ElementDB.element_model_by_id(_element_id) if model_override == null else model_override
	if _model == null:
		return
	# Name
	$ElemName.text = _model.name
	$ElemName.get_font("font").set_size(0.21875 * rect_size.y)
	# Colors
	$ElemSquare.modulate = _model.color
	$ElemName.add_color_override("font_color", Color.from_hsv(0, 0, 0 if 1 - _model.color.v < 0.2 else 1, 1))

func _on_gui_input(event):
	handle_gui_input(event)
