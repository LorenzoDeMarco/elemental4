extends Node

const CACHE_DIR_PATH = "user://cache"
const CACHE_PATH = "user://cache/%s_%s.cep"

var remote_head_url: String
var remote_sync_url: String

signal picture_ready(pack, id)
signal picture_error(pack, id)

var _requests: Dictionary = {}
var _rqmutex: Mutex = Mutex.new()

func _init():
	remote_head_url = Globals.get_primary_server() + "/api/universe/elements/pictures/count"
	remote_sync_url = Globals.get_primary_server() + "/api/universe/elements/pictures"
	connect("picture_ready", self, "_on_pic_ready")
	connect("picture_error", self, "_on_pic_error")

# callback function is in the form f(pack: String, id: String, success: bool, {extra..})
func provide_picture(pack: String, id: String, url: String, target, funcname: String, extra = null):
	var k = "%s_%s" % [pack, id]
	var rdat = {
		'target': target,
		'funcname': funcname,
		'extra': extra
	}
	_rqmutex.lock()
	if k in _requests:
		_requests[k].append(rdat)
	else:
		_requests[k] = [rdat]
	_rqmutex.unlock()
	download_picture(pack, id, url)

func _on_pic_ready(pack, id):
	var k = "%s_%s" % [pack, id]
	_rqmutex.lock()
	if k in _requests:
		for rq in _requests[k]:
			funcref(rq['target'], rq['funcname']).call_func(pack, id, true, rq['extra'])
		_requests.erase(k)
	_rqmutex.unlock()

func _on_pic_error(pack, id):
	var k = "%s_%s" % [pack, id]
	_rqmutex.lock()
	if k in _requests:
		for rq in _requests[k]:
			funcref(rq['target'], rq['funcname']).call_func(pack, id, false, rq['extra'])
		_requests.erase(k)
	_rqmutex.unlock()

func has_picture(pack: String, id: String) -> bool:
	return File.new().file_exists(CACHE_PATH % [pack, id])

func get_picture(pack: String, id: String) -> Texture:
	var image = Image.new()
	if image.load(CACHE_PATH % [pack, id]) != OK:
		return null
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func download_picture(pack: String, id: String, url: String):
	HTTPUtil.request(funcref(self, "_on_picture"), HTTPClient.METHOD_GET, \
		url, PoolStringArray(), "", false, [pack, id])

func _on_picture(resp: HTTPUtil.Response, data: Array):
	if resp.response_code >= 200 and resp.response_code < 300:
		# Prepare folder
		var d: Directory = Directory.new()
		if (not d.dir_exists(CACHE_DIR_PATH)) and \
			(d.make_dir_recursive(CACHE_DIR_PATH) != OK):
				return
		# Cache the image
		var f: File = File.new()
		if f.open(CACHE_PATH % data, File.WRITE) != OK:
			return
		f.store_buffer(resp.body)
		f.close()
		emit_signal("picture_ready", data[0], data[1])
	else:
		emit_signal("picture_error", data[0], data[1])
