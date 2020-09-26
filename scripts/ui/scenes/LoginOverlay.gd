extends Control

var _pwh: String = ""

func _ready():
	# "(New user)" meta profile
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.add_item("(New user)", \
		preload("res://assets/ui/icons/anonymous.png"))
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.set_item_metadata(0, null)
	# Existing profiles
	var mgr = Player.get_profiles_manager()
	mgr.scan_profiles()
	for id in mgr.get_profile_ids():
		var profile: Player.PlayerProfile = mgr.get_profile_by_id(id)
		if profile != null:
			var idx = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.get_item_count()
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.add_item(profile.username, \
				preload("res://assets/ui/icons/anonymous.png"))
			$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.set_item_metadata(idx, profile)
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.select(0)

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
	# Migrate password away from UI
	if _pwh == "" or (_pwh.length() > 0 and $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text != ""):
		_pwh = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text
	# Check field values
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.right_icon = null
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.right_icon = null
	var errc = 0
	var usern = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text.strip_edges()
	var passw = _pwh.strip_edges()
	if usern.length() == 0:
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.grab_focus()
		errc += 1
	if passw.length() == 0:
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		if errc == 0 and $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.editable: $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.grab_focus()
		errc += 1
	if errc > 0: return
	Player.connect("signin_state_changed", self, "_on_signin_state_changed", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	if Player.online_signin(usern, passw.sha256_text(), $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/RememberMe.pressed) != OK:
		_on_signin_state_changed(false)


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
	if Player.online_signup(usern, passw.sha256_text(), email) != OK:
		_on_signin_state_changed(false)

func _on_profile_selected(index: int):
	$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/PassTxt.text = ""
	if index == 0: # New user
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.editable = true
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text = ""
		_pwh = ""
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/RememberMe.pressed = false
	else: # Existing profile
		var profiledata = $Center/VBody/AutoPanel/VMain/Tabs/LoginTab/ProfilesList.get_item_metadata(index)
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.editable = false
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/UsernameTxt.text = profiledata.username
		_pwh = profiledata.pwh
		$Center/VBody/AutoPanel/VMain/Tabs/LoginTab/LoginBody/RememberMe.pressed = true
