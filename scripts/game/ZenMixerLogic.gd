extends Node

export var mixer_slots : Array
export var target_slot : NodePath
export var suggest_new_btn : NodePath
export var suggest_container : NodePath

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
	get_node(suggest_new_btn).visible = false
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
			var sfxp = Globals.get_game_sfx_player()
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
		# Trigger achievement
		_mixed_elements(ElementDB.element_model_by_id(formula_mdl.output_id))
	else:
		get_node(suggest_new_btn).visible = true
		_has_result = false

func _on_result_lifted(_position, inputs: Array):
	if consume_inputs:
		for slot in mixer_slots:
			# Zen Mode logic
			var emdl: ElementModel = get_node(slot).get_item().get_element_model()
			
			# Clear slot
			get_node(slot).clear_items()
		# Destroy inputs
		for input in inputs:
			input.queue_free()
	_has_result = false
	if auto_duplicate:
		_on_inventory_update(null, null)

func _mixed_elements(result: ElementModel):
	var curr_pack = ElementDB.get_pack_name()
	var profile = Player.get_profile()
	if not profile.discovered_elements.has(curr_pack):
		profile.discovered_elements[curr_pack] = []
		profile.emit_signal("achievement_done", "universe.first_mix_of_pack", [result, curr_pack])
	if not result.id in profile.discovered_elements[curr_pack]:
		profile.discovered_elements[curr_pack].append(result.id)
		profile.emit_signal("achievement_done", "universe.mix_new_element", result)

func _on_suggest_pressed():
	# Get inputs
	var inputs = []
	var in_items = []
	for slot in mixer_slots:
		var i = get_node(slot).get_item()
		if i != null: in_items.append(i)
	if in_items.size() < 2: return
	for element_node in in_items:
		inputs.append(element_node.get_element_id())
	# Show "suggest formula" overlay
	var sgui = preload("res://scenes/hud/SuggestFormulaOverlay.tscn").instance()
	sgui.formula_input_ids = inputs
	get_node(suggest_container).add_child(sgui)
