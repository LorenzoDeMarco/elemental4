extends Panel

func _ready():
	$Version.text = GlobalSettings.VERSION
	Player.connect("username_changed", self, "_on_username_changed")
	Player.connect("signin_state_changed", self, "_on_signin_state_changed")
	GlobalSettings.connect("internet_status_changed", self, "_on_internet_state_changed")
	if GlobalSettings.internet_access:
		get_parent().add_child(preload("res://scenes/hud/LoginOverlay.tscn").instance())
	else:
		_on_internet_state_changed(false)
	get_tree().get_root().add_child(preload("res://scenes/hud/NotificationOverlay.tscn").instance())

func _on_username_changed(username: String):
	$Username.text = username

func _on_signin_state_changed(state: bool):
	if not state:
		$Username.text = "Not signed in"
		$Stats.text = "0 eC - lv. 0"

func _on_internet_state_changed(state: bool):
	if not state:
		$Username.text = "Offline mode"
		$Stats.text = "0 eC - lv. 0"


func _goto_universemap():
	get_tree().change_scene("res://scenes/universe_map/UniverseMap.tscn")
