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

func date_dict_to_ISO(dict: Dictionary, timezone_offset_minutes: int = 0) -> String:
	return \
		String(dict.year) + "-" + \
		String(dict.month) + "-" + \
		String(dict.day) + "T" + \
		String(dict.hour) + ":" + \
		String(dict.minute) + ":" + \
		String(dict.second) + ".000" + (
			"Z" if timezone_offset_minutes == 0
			else (
				("+" if timezone_offset_minutes > 0 else "-") + \
				String(int(floor(timezone_offset_minutes / 60))) + ":" + \
				String(timezone_offset_minutes % 60)
			)
		)

func date_dict_from_ISO(iso: String) -> Dictionary:
	var tmp: Dictionary = {}
	var ln = iso.length()
	if ln >= 4:
		tmp['year'] = int(iso.substr(0, 4))
	if ln >= 7:
		if iso[4] != '-': return {}
		tmp['month'] = int(iso.substr(5, 2))
	if ln >= 10:
		if iso[7] != '-': return {}
		tmp['day'] = int(iso.substr(8, 2))
	tmp['hour'] = 0
	tmp['minute'] = 0
	tmp['second'] = 0
	tmp['weekday'] = 0
	if 'T' in iso:
		if ln < 16: return {}
		tmp['hour'] = int(iso.substr(11, 2))
		if iso[13] != ':': return {}
		tmp['minute'] = int(iso.substr(14, 2))
		tmp['utc'] = iso.find_last("Z") != -1
		if ln > 16 and iso[16] == ':':
			tmp['second'] = int(iso.substr(17, 2))
	return tmp

func date_dict_to_readable(dict: Dictionary, 
	format: String = "{day}/{month}/{year} {hour}:{minute}:{second}") -> String:
	var tmp : Dictionary = {}
	tmp['year'] = ("%04d" % dict.year) if 'year' in dict else '1970'
	tmp['month'] = ("%02d" % dict.month) if 'month' in dict else '01'
	tmp['day'] = ("%d" % dict.day) if 'day' in dict else '1'
	tmp['hour'] = ("%02d" % dict.hour) if 'hour' in dict else '00'
	tmp['minute'] = ("%02d" % dict.minute) if 'minute' in dict else '00'
	tmp['second'] = ("%02d" % dict.second) if 'second' in dict else '00'
	return format.format(tmp)
