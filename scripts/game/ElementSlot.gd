extends Control

var _accept_drop : bool

var _contents: Array = []

export var allow_stack : bool
export var is_input : bool setget accept_drop, accepts_drop

signal drop(element, position)
signal lift(element, position)

signal element_in(element)
signal element_out(element)

func accept_drop(enable: bool):
	_accept_drop = enable

func accepts_drop() -> bool:
	return _accept_drop and (_contents.size() == 0 or allow_stack)

func snap_elements() -> bool:
	return accepts_drop()

func _ready():
	connect("drop", self, "_on_drop")
	connect("lift", self, "_on_lift")

func _on_drop(element: Element, position):
	if accepts_drop():
		element.set_parent_container(self)
		if allow_stack:
			_contents.append(element)
			emit_signal("element_in", element)
		elif _contents.size() == 0:
			_contents = [element]
			emit_signal("element_in", element)
		else:
			element.set_parent_container(null)
			element.restore_source_position()

func _on_lift(element, position):
	if _contents.has(element):
		element.set_parent_container(null)
		var idx = _contents.find(element) + 1
		_contents.erase(element)
		if allow_stack:
			while idx < _contents.size() and _contents.size() > 1:
				_contents[idx].rect_global_position = _contents[idx].rect_global_position.move_toward(Vector2.DOWN, idx * 2)
				idx += 1
		emit_signal("element_out", element)

func get_item():
	return _contents[0] if _contents.size() > 0 else null

func get_items():
	return _contents

func _on_resized() -> void:
	rect_pivot_offset = Vector2(rect_size.x / 2, rect_size.y / 2)
