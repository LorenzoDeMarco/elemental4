extends Control

func _ready():
	var mgr = Player.get_profiles_manager()
	mgr.scan_profiles()
	for id in mgr.get_profile_ids():
		var profile: Player.PlayerProfile = mgr.get_profile_by_id(id)
		if profile != null:
			var idx = $Panel/TabContainer/LoginTab/ProfilesList.get_item_count()
			$Panel/TabContainer/LoginTab/ProfilesList.add_item(profile.username, \
				preload("res://assets/ui/icons/anonymous.png"))
			$Panel/TabContainer/LoginTab/ProfilesList.set_item_metadata(idx, profile)

func _switch_tab_register():
	$Panel/TabContainer.set_current_tab(1)

func _switch_tab_login():
	$Panel/TabContainer.set_current_tab(0)

func _on_signin_state_changed(signed_in: bool):
	if signed_in: queue_free()
	else:
		$Panel/TabContainer/LoginTab/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Panel/TabContainer/LoginTab/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")

func _on_login_pressed():
	# Check field values
	$Panel/TabContainer/LoginTab/UsernameTxt.right_icon = null
	$Panel/TabContainer/LoginTab/PassTxt.right_icon = null
	var errc = 0
	var usern = $Panel/TabContainer/LoginTab/UsernameTxt.text.strip_edges()
	var passw = $Panel/TabContainer/LoginTab/PassTxt.text.strip_edges()
	if usern.length() == 0:
		$Panel/TabContainer/LoginTab/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Panel/TabContainer/LoginTab/UsernameTxt.grab_focus()
		errc += 1
	if passw.length() == 0:
		$Panel/TabContainer/LoginTab/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		if errc == 0: $Panel/TabContainer/LoginTab/PassTxt.grab_focus()
		errc += 1
	if errc > 0: return
	Player.connect("signin_state_changed", self, "_on_signin_state_changed", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	if Player.online_signin(usern, passw.sha256_text(), $Panel/TabContainer/LoginTab/RememberMe.pressed) != OK:
		_on_signin_state_changed(false)


func _on_register_pressed():
	# Check field values
	$Panel/TabContainer/RegisterTab/UsernameTxt.right_icon = null
	$Panel/TabContainer/RegisterTab/PassTxt.right_icon = null
	$Panel/TabContainer/RegisterTab/EmailTxt.right_icon = null
	var errc = 0
	var usern = $Panel/TabContainer/RegisterTab/UsernameTxt.text.strip_edges()
	var passw = $Panel/TabContainer/RegisterTab/PassTxt.text.strip_edges()
	var email = $Panel/TabContainer/RegisterTab/EmailTxt.text.strip_edges()
	if usern.length() == 0:
		$Panel/TabContainer/RegisterTab/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Panel/TabContainer/RegisterTab/UsernameTxt.grab_focus()
		errc += 1
	if passw.length() == 0:
		$Panel/TabContainer/RegisterTab/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		if errc == 0: $Panel/TabContainer/RegisterTab/PassTxt.grab_focus()
		errc += 1
	var tm = Utility.regex_test_mail(email)
	if (not tm) or (tm.strings.size() == 0):
		$Panel/TabContainer/RegisterTab/EmailTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		if errc == 0: $Panel/TabContainer/RegisterTab/EmailTxt.grab_focus()
		errc += 1
	if errc > 0: return
