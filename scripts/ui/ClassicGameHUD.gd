extends Panel

export var element_size : Vector2 = Vector2(64, 64)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initial elements (air, water, fire, earth)
	var base : int = 0
	for i in range(5):
		var elem_node = preload("res://prefabs/ui/Element.tscn").instance()
		elem_node.rect_size = element_size
		elem_node.set_element_id(base + i if i != 4 else base)
		$ElementsCollector.add_element(elem_node)
		$ElementsCollector.drop_element_on(elem_node, get_node("QADropzone/QASlot" + str(i + 1)))


func _on_nosfxbtn_toggled(button_pressed: bool) -> void:
	GlobalSettings.set_gamesfx_enabled(not button_pressed)
	GlobalSettings.set_uisfx_enabled(not button_pressed)


func _on_pause_pressed() -> void:
	add_child(preload("res://scenes/hud/PauseOverlay.tscn").instance())
	get_tree().set_pause(true)
