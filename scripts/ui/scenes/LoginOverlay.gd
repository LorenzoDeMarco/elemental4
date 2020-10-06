extends Control

var _pwh: String = ""
var _id: String = ""
var _at_least_once: bool = false

func _ready():
	if Globals.internet_access:
		# "(New user)" meta profile
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.add_item("(New user)", \
			preload("res://assets/ui/icons/anonymous.png"))
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.set_item_metadata(0, null)
	else:
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/Register.disabled = true
	# Existing profiles
	var mgr = Player.get_profiles_manager()
	mgr.scan_profiles()
	for id in mgr.get_profile_ids():
		var profile: Player.PlayerProfile = mgr.get_profile_by_id(id)
		if profile != null:
			var idx = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.get_item_count()
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.add_item(profile.username, \
				preload("res://assets/ui/icons/anonymous.png"))
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.set_item_metadata(idx, [id, profile])
	if $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.items.size() > 0:
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.select(0)
		_on_profile_selected(0)

func _switch_tab_register():
	$Center/VBody/AutoPanel/VMain/Tabs.set_current_tab(1)

func _switch_tab_login():
	$Center/VBody/AutoPanel/VMain/Tabs.set_current_tab(0)

func _on_signin_state_changed(signed_in: bool):
	if signed_in: queue_free()
	else:
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")

func _on_login_pressed():
	# Check field values
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.right_icon = null
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.right_icon = null
	var errc = 0
	var usern = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text.strip_edges()
	var passw: String = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text.strip_edges()
	if usern.length() == 0:
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.grab_focus()
		errc += 1
	if passw.length() == 0:
		if _pwh == "":
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")
			if errc == 0 and $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.editable: $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.grab_focus()
			errc += 1
		else:
			passw = _pwh
	else:
		passw = passw.sha256_text()
	if errc > 0: return
	Player.connect("signin_state_changed", self, "_on_signin_state_changed", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	if not _at_least_once:
		while not Globals.internet_access:
			Globals.add_notification_k("oobe_offline")
			yield(get_tree().create_timer(5), "timeout")
			Globals.check_internet()
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/Register.disabled = false
	if Player.online_signin(usern, passw, $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/RememberMe.pressed) != OK:
		_on_signin_state_changed(false)
	else:
		Player.get_profile().load_by_id(_id)

func _on_signup_response(response: HTTPUtil.Response):
	match response.response_code:
		200:
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.select(0)
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text = \
				$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/UsernameTxt.text
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text = \
				$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/PassTxt.text
			_switch_tab_login()
		400:
			$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
			$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/EmailTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		500:
			print_debug("Got 500 in signup response!")
	$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/PassTxt.text = ""

func _on_register_pressed():
	# Check field values
	$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/UsernameTxt.right_icon = null
	$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/PassTxt.right_icon = null
	$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/EmailTxt.right_icon = null
	var errc = 0
	var usern = $Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/UsernameTxt.text.strip_edges()
	var passw = $Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/PassTxt.text.strip_edges()
	var email = $Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/EmailTxt.text.strip_edges()
	if usern.length() == 0:
		$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/UsernameTxt.grab_focus()
		errc += 1
	if passw.length() == 0:
		$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		if errc == 0: $Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/PassTxt.grab_focus()
		errc += 1
	var tm = Utility.regex_test_mail(email)
	if (not tm) or (tm.strings.size() == 0):
		$Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/EmailTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		if errc == 0: $Center/VBody/AutoPanel/VMain/Tabs/RegisterTab/EmailTxt.grab_focus()
		errc += 1
	if errc > 0: return
	Player.connect("signin_state_changed", self, "_on_signin_state_changed", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	if Player.online_signup(usern, passw.sha256_text(), email, funcref(self, "_on_signup_response")) != OK:
		_on_signin_state_changed(false)

func _on_profile_selected(index: int):
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text = ""
	if index == 0 and Globals.internet_access: # New user
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.editable = true
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text = ""
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text = ""
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.placeholder_text = ""
		_pwh = ""
		_id = ""
		_at_least_once = false
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/RememberMe.pressed = false
	else: # Existing profile
		var profiledata = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.get_item_metadata(index)
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.editable = false
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text = profiledata[1].username
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text = ""
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.placeholder_text = "(saved)"
		_pwh = profiledata[1].pwh
		_id = profiledata[0]
		_at_least_once = true
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/RememberMe.pressed = true
