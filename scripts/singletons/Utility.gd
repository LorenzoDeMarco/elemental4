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

func get_controls_intersecting(target: Control, parent: Node, max_depth: int = 0) -> Array:
	# Get own rectangle
	var own_rect = Rect2(target.rect_global_position, target.rect_size)
	var found = []
	var clip_max : int = 0
	if max_depth == -1 and parent is Control and own_rect.clip(parent.get_global_rect()).get_area() > 0:
		return [parent]
	for node in parent.get_children():
		if node == target: continue
		if node is Control:
			var clip_area = own_rect.clip(node.get_global_rect()).get_area()
			if clip_area > clip_max:
				found.insert(0, node)
				clip_max = clip_area
				if max_depth > 0:
					for n in get_controls_inside(target, node, max_depth - 1):
						found.append(n)
	return found

func element_model_from_dto(dto: Dictionary) -> ElementModel:
	if dto == null or dto.size() == 0: return null
	var id: int = ElementModel.ID_NONE if dto['id'] < ElementModel.ID_NONE else dto['id']
	var name: String = dto['name']
	var color: Color = Color(dto['color'])
	#var birth: int = int(dto['birthTime']) if dto['birthTime'] is String else dto['birthTime']
	var mark: String = dto['mark'] if 'mark' in dto else ""
	#var original_eq: int = int(dto['originalEquation']) if dto['originalEquation'] is String else dto['originalEquation']
	return ElementModel.new(id, name, color, mark)

func formula_model_from_dto(dto: Dictionary) -> FormulaModel:
	if dto == null or dto.size() == 0: return null
	var id: int = dto['id']
	var inputs: Array = dto['inputs']
	inputs.sort()
	var output: int = dto['output']
	var birth: int
	if dto.has('birthTime'):
		birth = int(dto['birthTime']) if dto['birthTime'] is String else dto['birthTime']
	else:
		birth = int(dto['birth']) if dto['birth'] is String else dto['birth']
	var votes: int = dto['votes']
	var consensus: int = dto['consensus']
	var new_element: bool = dto['isNewElement']
	return FormulaModel.new(id, inputs, output, new_element, birth, votes, consensus)

func internet_test() -> bool:
	var hc = HTTPClient.new()
	var err = hc.connect_to_host("example.com", 80)
	if err != OK: return false
	while hc.get_status() == HTTPClient.STATUS_CONNECTING or hc.get_status() == HTTPClient.STATUS_RESOLVING:
		hc.poll()
		OS.delay_msec(500)
	hc.close()
	return hc.get_status() == HTTPClient.STATUS_CONNECTED
