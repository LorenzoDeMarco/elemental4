extends Control

const elem_scene = preload("res://prefabs/ui/Element.tscn")
const ELEM_SIZE = Vector2(80, 80)

var zoom_factor = Vector2(1, 1)

var _target_zoom = Vector2(-INF, -INF)

const ORIGIN = Vector2(0.5, 0.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	ElementDB.populate_db()
	$MultiMeshInstance2D.multimesh.instance_count = ElementDB._db.size()
	var k = 0
	for i in ElementDB._db.keys():
		_add_element(k, i)
		k += 1


func _elem_pos(model: ElementModel) -> Vector2:
	var dist = model.id + (model._birth - 1470780624) / 60
	var orig = ORIGIN * rect_size
	seed(model._birth + model.id)
	var a = PI * randf() * 2
	return Vector2(orig.x + dist * cos(a), orig.y + dist * sin(a))

func _add_element(idx: int, id: int):
	var mdl = ElementDB.element_model_by_id(id)
	var pos = _elem_pos(mdl)
	$MultiMeshInstance2D.multimesh.set_instance_transform_2d(idx, \
		Transform2D(0, pos))
	$MultiMeshInstance2D.multimesh.set_instance_color(idx, mdl.color)
	
#	var elem = elem_scene.instance()
#	elem.animate = false
#	elem.rect_min_size = ELEM_SIZE
#	elem.can_be_dragged = false
#	elem.set_element_id(id)
#	elem.name = str(id)
#	add_child(elem)
#	elem.rect_global_position = _elem_pos(ElementDB.element_model_by_id(id))
#	return elem

func anim_cam_zoom(target_zoom: Vector2):
	#if $Camera2D/Tween.is_active():
	#	$Camera2D/Tween.stop($Camera2D, "zoom")
	_target_zoom = target_zoom
	$Camera2D/Tween.interpolate_property($Camera2D, "zoom", $Camera2D.zoom, _target_zoom, 0.4)
	if not $Camera2D/Tween.is_active():
		$Camera2D/Tween.start()

func zoom_out(mult):
	anim_cam_zoom($Camera2D.zoom - (Vector2(0.3, 0.3) * mult))

func zoom_in(mult):
	anim_cam_zoom($Camera2D.zoom + (Vector2(0.3, 0.3) * mult))

func _input(event: InputEvent):
	if event.is_pressed() and event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_in(event.factor * zoom_factor)
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_out(event.factor * zoom_factor)
	elif event is InputEventKey:
		if event.scancode == KEY_CONTROL:
			zoom_factor = Vector2(6, 6) if event.pressed else Vector2(1, 1)
