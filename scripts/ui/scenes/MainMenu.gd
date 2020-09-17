extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_child(preload("res://scenes/hud/LoginOverlay.tscn").instance())
	Player.connect("username_changed", self, "_on_username_changed")
	Player.connect("signin_state_changed", self, "_on_signin_state_changed")

func _on_username_changed(username: String):
	$Username.text = username

func _on_signin_state_changed(state: bool):
	if not state:
		$Username.text = "Not signed in"
		$Stats.text = "0 eC - lv. 0"
