extends Control

const elem_scene = preload("res://prefabs/ui/Element.tscn")
const ELEM_SIZE = Vector2(80, 80)

const ORIGIN = Vector2(0.5, 0.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(200):
		_add_element(i)


func _elem_pos(model: ElementModel) -> Vector2:
	var dist = model.id + (model._birth - 1470780624) / 60
	var orig = ORIGIN * rect_size
	seed(model._birth + model.id)
	var a = PI * randf() * 2
	return Vector2(orig.x + dist * cos(a), orig.y + dist * sin(a))

func _add_element(id: int) -> Element:
	var elem = elem_scene.instance()
	elem.animate = false
	elem.rect_min_size = ELEM_SIZE
	elem.can_be_dragged = false
	elem.set_element_id(id)
	elem.name = str(id)
	add_child(elem)
	elem.rect_global_position = _elem_pos(ElementDB.element_model_by_id(id))
	return elem

func zoom_out():
	rect_size *= 0.9

func zoom_in():
	rect_size /= 0.9

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask & BUTTON_WHEEL_DOWN > 0:
			zoom_out()
		if event.button_mask & BUTTON_WHEEL_UP > 0:
			zoom_in()
