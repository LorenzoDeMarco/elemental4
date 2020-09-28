extends Control

var wait_frames_base = 20
var wait_frames
var time_max = 100 # msec
var current_scene
var loader: ResourceInteractiveLoader

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	loader = ResourceLoader.load_interactive(Globals.target_scene_path)
	$ProgressBar.max_value = loader.get_stage_count()
	set_process(true)
	wait_frames = wait_frames_base * 3

func _process(delta: float):
	if loader == null:
		set_process(false)
		return
	if wait_frames > 0:
		wait_frames -= 1
		return
	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			return
		elif err == OK:
			$ProgressBar.value = loader.get_stage()
		else: # Error during loading.
			printerr("Failed to load scene.")
			loader = null
			return
	wait_frames = wait_frames_base

func set_new_scene(sceneres: Resource):
	current_scene.queue_free()
	get_tree().get_root().add_child(sceneres.instance())
