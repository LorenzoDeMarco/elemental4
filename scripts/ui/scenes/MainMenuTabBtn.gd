extends ToolButton

export var tab_container: NodePath

func _ready():
	connect("pressed", self, "_on_pressed")

func _on_pressed():
	var idx: int = get_parent().get_children().find(self)
	if idx > -1 and tab_container != null:
		var tc = get_node(tab_container)
		if tc.has_method('set_current_tab'):
			tc.set_current_tab(idx)
