extends CanvasLayer
class_name PauseScreenMenu

onready var menu = $Control
onready var items : Array = [$Control/ResumeButton, $Control/RestartButton, $Control/TitleButton]

var sound
var ready_yes = false
var options = load("res://Scenes/Options.tscn")

func _ready():
	$Control/ResumeButton.grab_focus()
	get_tree().paused = false
	menu.visible = false
	set_process_input(true)
	set_pause_mode(PAUSE_MODE_PROCESS)
	sound = AudioStreamPlayer2D.new()
	sound.stream = load("res://Sounds/Pause.wav")
	call_deferred("add_child", sound)
	ready_yes = true
	
func _input(event):
	if event.is_action_pressed("pause"):
		sound.stream = load("res://Sounds/Pause.wav")
		sound.play()
		var state = not get_tree().paused
		get_tree().set_pause(not get_tree().paused)
		menu.visible = state

func _entered1():
	if ready_yes:
		print('yes')
		sound.stream = load("res://Sounds/Menu.wav")
		sound.play()

func _entered2():
	if ready_yes:
		print('yes')
		sound.stream = load("res://Sounds/Menu.wav")
		sound.play()

func _entered3():
	if ready_yes:
		print('yes')
		sound.stream = load("res://Sounds/Menu.wav")
		sound.play()

func resume_pressed():
	sound.stream = load("res://Sounds/Pause.wav")
	sound.play()
	var state = not get_tree().paused
	get_tree().set_pause(not get_tree().paused)
	menu.visible = state

func restart_pressed():
	menu.visible = false
	get_parent().get_node("Player")._reset()

func titlebutton_pressed():
	Transitions.slide_rect2(get_parent(), "res://Scenes/Title Screen.tscn", 2, Color.black, Vector2(-2, 0))

func _pressed_Options():
	get_tree().root.add_child(options.instance())

func _on_OptionsButton_focus_entered():
	if ready_yes:
		print('yes')
		sound.stream = load("res://Sounds/Menu.wav")
		sound.play()
