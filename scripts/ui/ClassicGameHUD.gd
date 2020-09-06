extends Panel

const INVENTORY_ORIGIN = Vector2(16, 96)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initial elements (air, water, fire, earth)
	var origin = INVENTORY_ORIGIN
	var base : int = 0
	var count : int = 2
	var num : int = 0
	for i in range(4):
		for c in range(count):
			if num % 5 == 0:
				origin += Vector2(68, 0)
			var elem_node = preload("res://prefabs/ui/Element.tscn").instance()
			elem_node.set_element_id(base + i)
			elem_node.set_position(origin + Vector2(0, 68 * int(num % 5)))
			$ElementsCollector.add_element(elem_node)
			num += 1
