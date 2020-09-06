extends Dropzone

var _items : Array = []

func _init():
	connect("drop", self, "_on_drop")
	connect("lift", self, "_on_lift")

func _on_drop(element, position):
	_items.append(element)

func _on_lift(element, position):
	_items.erase(element)

func get_items() -> Array:
	return _items

func set_items(items: Array):
	_items = items

func add_item(item):
	_items.append(item)

func clear_items():
	_items.clear()
