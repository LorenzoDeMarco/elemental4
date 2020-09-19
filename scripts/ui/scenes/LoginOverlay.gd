extends Control

func _ready():
	pass

func _switch_tab_register():
	$Panel/TabContainer.set_current_tab(1)

func _switch_tab_login():
	$Panel/TabContainer.set_current_tab(0)

func _on_signin_state_changed(signed_in: bool):
	if signed_in: queue_free()
	else:
		$Panel/TabContainer/LoginTab/UsernameTxt.right_icon = preload("res://assets/ui/icon_excl.png")
		$Panel/TabContainer/LoginTab/PassTxt.right_icon = preload("res://assets/ui/icon_excl.png")

func _on_login_pressed() -> void:
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
