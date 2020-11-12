extends Control
class_name FormFactorSwitcher
tool

enum FormFactor {
	DESKTOP = 0,
	MOBILE = 1,
	MOBILE_PORTRAIT = 2
}

var _ff: int = FormFactor.DESKTOP

export(FormFactor) var form_factor setget set_form_factor, get_form_factor

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child.has_method('set_visible'):
			child.set_visible(false)
	_update_form_factor()

func set_form_factor(value: int):
	var is_diff = value != _ff
	_ff = value if value >= 0 and value <= 2 else FormFactor.DESKTOP
	if is_diff:
		_update_form_factor()

func get_form_factor() -> int:
	return _ff

func _update_form_factor():
	var parent = get_parent()
	if parent.has_method('set_size') and Engine.editor_hint:
		match _ff:
			FormFactor.MOBILE_PORTRAIT:
				parent.set_size(Vector2(1080, 1920))
			_:
				parent.set_size(Vector2(1920, 1080))
	for i in range(get_child_count()):
		var c = get_child(i)
		if c.has_method('set_visible'):
			c.set_visible(i == _ff)
