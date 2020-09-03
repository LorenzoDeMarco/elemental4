extends NinePatchRect

var _gray : bool = false

export var use_gray_texture : bool setget set_gray_texture, has_gray_texture

func set_gray_texture(enabled: bool):
	_gray = enabled
	_update_texture()

func has_gray_texture() -> bool:
	return _gray

func _update_texture():
	if _gray:
		texture = preload("res://assets/ui/elem_square_grayscale.png")
	else:
		texture = preload("res://assets/ui/elem_square.png")

func _init():
	_update_texture()
