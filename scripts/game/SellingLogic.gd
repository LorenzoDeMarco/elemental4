extends Node

export var slot : NodePath

func _ready():
	if slot == null: return
	var n = get_node(slot)
	if n == null: return
	n.connect("element_in", self, "_on_slot_input", [n])

func _on_slot_input(element, slot):
	# Delete element
	slot.get_items().erase(element)
	element.queue_free()
