extends Node

func get_controls_inside(target: Control, parent: Node, max_depth: int = 0) -> Array:
	# Get own rectangle
	var own_rect = Rect2(target.rect_global_position, target.rect_size)
	var found = []
	for node in parent.get_children():
		if node is Control and own_rect.has_point(node.rect_global_position):
			found.append(node)
			if max_depth > 0:
				for n in get_controls_inside(target, node, max_depth - 1):
					found.append(n)
	return found
