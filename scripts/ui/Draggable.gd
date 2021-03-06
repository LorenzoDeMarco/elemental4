extends Control
class_name Draggable

var _dragging = false

export var can_be_dragged : bool = true
export var is_slot : bool = false

var drag_source_position: Vector2 = Vector2.INF

signal begin_drag(position)
signal end_drag(position)

func _process(_delta):
	if _dragging and can_be_dragged:
		var mousepos = get_viewport().get_mouse_position()
		self.set_global_position(Vector2(mousepos.x, mousepos.y) - (self.rect_size / 2))

func restore_source_position():
	if drag_source_position != Vector2.INF:
		self.set_global_position(drag_source_position)
		drag_source_position = Vector2.INF

func handle_gui_input(event):
	if can_be_dragged:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				_dragging = event.pressed
				if _dragging:
					drag_source_position = rect_global_position
					emit_signal("begin_drag", event.position)
				else:
					emit_signal("end_drag", event.position)
		elif event is InputEventScreenTouch:
			if event.pressed and event.get_index() == 0:
				self.set_global_position(event.get_position())
