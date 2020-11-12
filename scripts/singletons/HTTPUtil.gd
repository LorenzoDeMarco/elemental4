extends Node

class Response:
	var result: int
	var response_code: int
	var headers: PoolStringArray
	var body: PoolByteArray

func _register_httprequest(alias: String) -> HTTPRequest:
	var tmp = HTTPRequest.new()
	tmp.name = "HTTP" + alias
	add_child(tmp)
	return tmp

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _on_request_completed(result, response_code, headers, body, handler: HTTPRequest, callbackfn: FuncRef, extra = null):
	var tmp : Response = Response.new()
	tmp.result = result
	tmp.response_code = response_code
	tmp.headers = headers
	tmp.body = body
	handler.queue_free()
	if response_code == 0: return
	if callbackfn != null:
		if extra != null:
			callbackfn.call_func(tmp, extra)
		else:
			callbackfn.call_func(tmp)

func request(callback: FuncRef, method: int, url: String, headers: PoolStringArray = PoolStringArray(), body: String = "", token: bool = true, extra = null) -> int:
	var handler : HTTPRequest = _register_httprequest(String(randi() % 1000))
	var tmp_headers = headers
	if token and Player._token.length() > 0:
		tmp_headers.append("Authorization: Bearer " + Player._token)
	handler.connect("request_completed", self, "_on_request_completed", [handler, callback, extra], CONNECT_DEFERRED | CONNECT_ONESHOT)
	return handler.request(url, tmp_headers, true, method, body)
