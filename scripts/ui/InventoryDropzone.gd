extends Dropzone

var _items : Array = []

export var grid_snap : bool = true
export var grid_origin : Vector2 = Vector2(6, 6)
export var grid_size : Vector2 = Vector2(1.05, 1.05)

func _init():
	connect("drop", self, "_on_drop")
	connect("lift", self, "_on_lift")

func _on_drop(element : Element, position):
	element.set_parent_container(self)
	_items.append(element)
	if grid_snap:
		var pos = rect_global_position \
			+ grid_origin \
			+ (element.rect_global_position - rect_global_position).snapped(grid_size)
		if get_global_rect().encloses(Rect2(pos, element.rect_size)):
			element.rect_global_position = pos
		else:
			_items.erase(element)
			element.restore_source_position()

func _on_lift(element, position):
	element.set_parent_container(null)
	_items.erase(element)

func get_items() -> Array:
	return _items

func set_items(items: Array):
	_items = items

func add_item(item):
	_items.append(item)

func clear_items():
	_items.clear()
