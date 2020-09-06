extends Control

var _accept_drop : bool

export var is_input : bool setget accept_drop, accepts_drop

signal drop(element, position)

func accept_drop(enable: bool):
	_accept_drop = enable

func accepts_drop() -> bool:
	return _accept_drop
