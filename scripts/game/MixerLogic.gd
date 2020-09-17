extends Node

export var mixer_slots : Array
export var target_slot : NodePath

export var consume_inputs : bool
export var auto_duplicate : bool

var _has_result: bool = false
var _result : NodePath

func _ready():
	for np in mixer_slots:
		var sn = get_node(np)
		sn.connect("element_in", self, "_on_inventory_update", [null])
		sn.connect("element_out", self, "_on_inventory_update", [null])

func _on_inventory_update(_element, _position):
	if mixer_slots == null or mixer_slots.size() == 0: return
	# Clear any previous result
	if _has_result:
		get_node(_result).queue_free()
		_has_result = false
	# Get formula with dropped elements
	var inputs = []
	var in_items = []
	for slot in mixer_slots:
		var i = get_node(slot).get_item()
		if i != null: in_items.append(i)
	if in_items.size() < 2: return
	for element_node in in_items:
		inputs.append(element_node.get_element_id())
	var formula_mdl : FormulaModel = FormulaDB.formula_by_inputs(inputs)
	if formula_mdl != null:
		if not _has_result:
			# Play popping sound
			var sfxp = GlobalSettings.get_game_sfx_player()
			if sfxp != null:
				sfxp.stop()
				sfxp.stream = preload("res://sounds/game/classic_pop.ogg")
				sfxp.play()
		_has_result = true
		# Make element from formula
		var elem_node : Element = preload("res://prefabs/ui/Element.tscn").instance()
		get_parent().bind_element(elem_node)
		elem_node.set_element_id(formula_mdl.output_id)
		# Destroy inputs when result is lifted
		elem_node.connect("begin_drag", self, "_on_result_lifted", [in_items], CONNECT_ONESHOT)
		# Snap to output slot
		var ts = get_node(target_slot)
		elem_node.set_global_position(ts.rect_global_position)
		elem_node.set_parent_container(ts)
		# Save for later
		_result = elem_node.get_path()
	else:
		_has_result = false

func _on_result_lifted(_position, inputs: Array):
	if consume_inputs:
		# Destroy inputs
		for input in inputs:
			input.queue_free()
	_has_result = false
	if auto_duplicate:
		_on_inventory_update(null, null)
