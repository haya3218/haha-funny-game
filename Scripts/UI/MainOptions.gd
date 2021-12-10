extends CanvasLayer

func _ready():
	$Keybinds.visible = false
	$Main/Control/Button.grab_focus()

func _physics_process(delta):
	if Input.is_action_just_pressed("options_press"):
		Globals.exited_options = true
		print(get_parent())
		if get_parent() is TitleScreenMenu:
			get_parent().get_node("StartButton").grab_focus()
			print('trol')
		queue_free()

func _on_keybinds_pressed():
	set_physics_process(false)
	$Keybinds.visible = true
