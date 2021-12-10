extends Control
class_name TitleScreenMenu

var sound
var input_dir = 0
var ready_yes = false
var options = load("res://Scenes/Options.tscn")

func _ready():
	set_process_input(true)
	$StartButton.grab_focus()
	sound = AudioStreamPlayer2D.new()
	sound.stream = load("res://Sounds/Menu.wav")
	call_deferred("add_child", sound)
	ready_yes = true
	Globals.set_game_binds()
	Globals.write_config()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		input_dir = -1
	elif Input.is_action_just_pressed("ui_down"):
		input_dir = 1
	
func _on_StartButton_pressed():
	var left = Vector2(-2, 0)
	sound.stream = load("res://Sounds/Accept.wav")
	sound.play()
	Transitions.slide_rect(self, "res://Scenes/Test.tscn", 2, Color.black, Vector2(-2, 0), false)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_StartButton_focus_entered():
	if ready_yes:
		print('yes')
		sound.play()

func _on_ExitButton_focus_entered():
	if ready_yes:
		print('yes')
		sound.play()

func _on_OptionsButton_pressed():
	self.add_child(options.instance())

func _on_OptionsButton_focus_entered():
	if ready_yes:
		print('yes')
		sound.play()
