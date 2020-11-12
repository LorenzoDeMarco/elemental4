extends Panel

func _ready():
	if Globals.is_mobile:
		$FormFactorSwitcher.set_form_factor(FormFactorSwitcher.FormFactor.MOBILE)
	else:
		$FormFactorSwitcher.set_form_factor(FormFactorSwitcher.FormFactor.DESKTOP)
	
	Player.connect("signin_state_changed", self, "_on_signin_state_changed")
	Globals.connect("internet_status_changed", self, "_on_internet_state_changed")
	var li = Player.is_logged_in()
	$SignInLnk.visible = not li
	if Globals.internet_access:
		_on_signin_state_changed(li)
	else:
		_on_internet_state_changed(false)
	if not li:
		_sign_in()
		
	var root = get_tree().get_root()
	root.call_deferred("add_child", preload("res://scenes/hud/NotificationOverlay.tscn").instance())

func _on_username_changed(username: String):
	$Username.text = username

func _on_signin_state_changed(state: bool):
	$SignInLnk.visible = not state
	if not state or Player.get_profile().id == Player.PlayerProfile.ID_DEFAULT:
		$Username.text = "Not signed in"
		$Stats.text = "0 eC - lv. 0"
		$SignInLnk.visible = true
	else:
		$Username.text = Player.get_profile().username
		$Stats.text = "0 eC - lv. 0"
		$SignInLnk.visible = false

func _on_internet_state_changed(state: bool):
	if not state:
		$Username.text = "Offline mode"
		$Stats.text = "0 eC - lv. 0"
		$SignInLnk.visible = not Player._logged_in

func _goto_universemap():
	Globals.move_to_scene("res://scenes/universe_map/UniverseMap.tscn")

func _sign_in():
	get_parent().add_child(preload("res://scenes/hud/LoginOverlay.tscn").instance())

func start_sp_zen() -> void:
	Globals.move_to_scene("res://scenes/game/ZenGame.tscn", Globals.BACKDROP_ZEN)

func start_sp_classic() -> void:
	Globals.move_to_scene("res://scenes/game/ClassicGame.tscn", Globals.BACKDROP_CLASSIC)
