extends Control

export var allow_element_stacking : bool = true
export var stacking_collectors_group : String

signal element_stacked(top_element, bottom)
signal element_lifted(element, position)

func add_element(element: Element):
	add_child(element)
	element.connect("begin_drag", self, "element_begin_drag", [element])
	element.connect("end_drag", self, "element_end_drag", [element])

func drop_element_on(element: Element, target: Control, position: Vector2 = Vector2.INF) -> bool:
	if target == null: return false
	if target.has_method("accepts_drop") and (not target.accepts_drop()):
		return false
	var snm: bool = target.has_method("should_snap")
	if snm and target.should_snap() or not snm:
		element.set_position(target.rect_global_position)
	emit_signal("element_stacked", element, target)
	if target.has_signal("drop"):
		target.emit_signal("drop", element, position if position != Vector2.INF else target.rect_global_position)
	return true

func lift_element_off(element: Element, source: Control, position: Vector2 = Vector2.INF) -> bool:
	if not source.has_signal("lift"):
		return false
	source.emit_signal("lift", element, position if position != Vector2.INF else element.rect_global_position)
	return true

func element_end_drag(position: Vector2, element: Element):
	var found = false
	if allow_element_stacking:
		for matched in get_collectors_with(element):
			if drop_element_on(element, matched, position):
				found = true
				break
	if not found: element.restore_source_position()

func get_collectors_with(element: Element) -> Array:
	var inside: Array = []
	for collector in get_tree().get_nodes_in_group(stacking_collectors_group):
		inside += Utility.get_controls_intersecting(element, collector, -1)
	inside += Utility.get_controls_intersecting(element, self)
	return inside

func element_begin_drag(position: Vector2, element: Element):
	# Bring element to front
	element.raise() # equivalent to:	move_child(element, get_child_count() - 1)
	# Notify others that the element is being lifted
	emit_signal("element_lifted", element, position)
	for matched in get_collectors_with(element):
		if lift_element_off(element, matched):
			break

func simulate_element_drag(element: Element, final_position: Vector2) -> bool:
	if not element.can_be_dragged: return false
	element_begin_drag(element.rect_global_position, element)
	element_end_drag(final_position, element)
	return true

func simulate_element_stacking(element: Element, target: Control) -> bool:
	if element.can_be_dragged:
		element_begin_drag(element.rect_global_position, element)
		return drop_element_on(element, target)
	return false
