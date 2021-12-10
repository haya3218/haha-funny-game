extends CanvasLayer
class_name PauseScreenMenu

onready var menu = $Control
onready var items : Array = [$Control/ResumeButton, $Control/RestartButton, $Control/TitleButton]

var sound
var ready_yes = false
var options = load("res://Scenes/Options.tscn")
var supposed_pause = false
var transitioning = false

func _ready():
	$Control/ResumeButton.grab_focus()
	get_tree().paused = false
	supposed_pause = false
	transitioning = false
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
		transitioning = false
		var state = not get_tree().paused
		get_tree().paused = not get_tree().paused
		supposed_pause = state
		menu.visible = state

func _process(delta):
	if not transitioning:
		get_tree().paused = supposed_pause

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
	transitioning = true
	sound.stream = load("res://Sounds/Pause.wav")
	sound.play()
	var state = not get_tree().paused
	get_tree().set_pause(not get_tree().paused)
	menu.visible = state

func restart_pressed():
	menu.visible = false
	get_parent().get_node("Player")._reset()

func titlebutton_pressed():
	transitioning = true
	menu.visible = false
	get_tree().paused = false
	Transitions.slide_rect(get_parent(), "res://Scenes/Load.tscn", 2, Color.black, Vector2(-2, 0), false)

func _pressed_Options():
	get_tree().root.add_child(options.instance())

func _on_OptionsButton_focus_entered():
	if ready_yes:
		print('yes')
		sound.stream = load("res://Sounds/Menu.wav")
		sound.play()
