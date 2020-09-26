extends Control

var loader_thread: Thread = null
var loader: ResourceInteractiveLoader
var do_process: bool = true

func _ready():
	var target_scene = Globals.target_scene_path
	Globals.target_scene_path = ""
	loader_thread = Thread.new()
	#return
	#if loader_thread.start(self, "_load_scene", target_scene, Thread.PRIORITY_HIGH) != OK:
	#	printerr("Failed to create thread to load scene %s." % target_scene)
	#	get_tree().quit(11)

func _load_scene(scene: String):
	loader = ResourceLoader.load_interactive(scene)
	if loader == null:
		printerr("Failed to create load scene %s." % scene)
		get_tree().quit(12)
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			_update_progress()
		else: # Error during loading.
			printerr("Failed to load scene %s." % scene)
			get_tree().quit(13)
			break

func _update_progress():
	pass

func set_new_scene(sceneres: Resource):
	get_tree().get_root().add_child(sceneres.instance())
	queue_free()
