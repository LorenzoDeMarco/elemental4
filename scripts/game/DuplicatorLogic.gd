extends Node

export var input_slot: NodePath
export var output_slot: NodePath

var _has_result: bool = false
var _result : NodePath

func _ready():
	var sn = get_node(input_slot)
	if sn != null:
		sn.connect("element_in", self, "_on_inventory_update", [null])
		sn.connect("element_out", self, "_on_inventory_update", [null])

func _on_inventory_update(_element, _position):
	if input_slot == null: return
	# Clear any previous result
	if _has_result:
		get_node(_result).queue_free()
		_has_result = false
	var input = get_node(input_slot).get_item()
	if input != null:
		if not _has_result:
			# Play popping sound
			var sfxp = Globals.get_game_sfx_player()
			if sfxp != null:
				sfxp.stop()
				sfxp.stream = preload("res://sounds/game/classic_pop.ogg")
				sfxp.play()
		_has_result = true
		# Duplicate element
		var elem_node : Element = preload("res://prefabs/ui/Element.tscn").instance()
		get_parent().bind_element(elem_node)
		elem_node.set_element_id(input.get_element_id())
		# Snap to output slot
		var ts = get_node(output_slot)
		elem_node.set_global_position(ts.rect_global_position)
		elem_node.set_parent_container(ts)
		# Prepare for subsequent duplications
		elem_node.connect("begin_drag", self, "_on_result_lifted", [], CONNECT_ONESHOT)
		# Save for later
		_result = elem_node.get_path()
	else:
		_has_result = false

func _on_result_lifted(_position):
	_has_result = false
	_result = ""
	_on_inventory_update(null, null)
