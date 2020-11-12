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
	var last_id = null
	for i in ElementDB._db.keys():
		_add_element(k, i)
		last_id = i
		k += 1
	$MultiMeshInstance2D.position = rect_size / 2
	# Text
	$RichTextLabel.text = $RichTextLabel.text % [
		$MultiMeshInstance2D.multimesh.instance_count,
		Utility.date_dict_to_readable(OS.get_datetime_from_unix_time(ElementDB.element_model_by_index(0)._birth)),
		_elem_pos(ElementDB.element_model_by_id(last_id)).length()
	]

func _elem_pos(model: ElementModel) -> Vector2:
	var dist = model.id + (model._birth - 1470780624) / 60.0
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
	_target_zoom = target_zoom
	_target_zoom.x = max(0.001, _target_zoom.x)
	_target_zoom.y = max(0.001, _target_zoom.y)
	$MultiMeshInstance2D.position = rect_size / 2
	$Camera2D/Tween.interpolate_property($MultiMeshInstance2D, "scale", $MultiMeshInstance2D.scale, _target_zoom, 0.4)
	if not $Camera2D/Tween.is_active():
		$Camera2D/Tween.start()

func zoom_out(mult = zoom_factor):
	anim_cam_zoom($MultiMeshInstance2D.scale - (Vector2(0.15, 0.15) * mult))

func zoom_in(mult = zoom_factor):
	anim_cam_zoom($MultiMeshInstance2D.scale + (Vector2(0.15, 0.15) * mult))

func _input(event: InputEvent):
	if event.is_pressed() and event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_in(event.factor * zoom_factor)
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_out(event.factor * zoom_factor)
	elif event is InputEventKey:
		if event.scancode == KEY_CONTROL:
			zoom_factor = Vector2(2, 2) if event.pressed else Vector2(1, 1)
