extends GameScene

func _ready() -> void:
	_connect_buttons()

func _connect_buttons() -> void:
	var vbox:VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer

	var tavern_btn: Button = vbox.get_node("Tavern")
	tavern_btn.pressed.connect(func(): requested_switch_scene.emit("tavern"))

	var spar_btn: Button = vbox.get_node("Spar")
	spar_btn.pressed.connect(func(): requested_switch_scene.emit("spar"))
	
	var battle_btn: Button = vbox.get_node("Battle")
	battle_btn.pressed.connect(func(): requested_switch_scene.emit("battle"))

	# Grab focus
	vbox.get_children()[0].grab_focus()
