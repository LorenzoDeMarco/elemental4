extends Control
class_name Dropzone

export var accept_drop : bool
export var snap_elements : bool

signal drop(element, position)
signal lift(element, position)

func should_snap() -> bool:
	return snap_elements

func accepts_drop() -> bool:
	return accept_drop
