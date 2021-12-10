extends Control

var can_change_key = false
var action_string
enum ACTIONS {walk_left, walk_right, jump, dash}
var current_keybinds
onready var but : Button = $Panel/walk_left/Button

func _ready():
	current_keybinds = Globals.keybinds.duplicate()
	Globals.set_game_binds()
	Globals.write_config()
	_set_keys()
	Globals.exited_options = false

func _set_keys():
	for j in ACTIONS:
		get_node("Panel/" + str(j) + "/Button").set_pressed(false)
		if !InputMap.get_action_list(j).empty():
			get_node("Panel/" + str(j) + "/Button").set_text(OS.get_scancode_string(InputMap.get_action_list(j)[0].scancode))
		else:
			get_node("Panel/" + str(j) + "/Button").set_text("No Button!")
			
func _process(delta):
	if Input.is_action_just_pressed("options_press"):
		visible = false
		get_parent().get_node("Main/Control/Button").grab_focus()
		yield(get_tree().create_timer(0.1), "timeout")
		get_parent().set_physics_process(true)
	if Input.is_action_just_pressed("space"):
		for j in ACTIONS:
			get_node("Panel/" + str(j) + "/Button").set_pressed(false)

func _left_pressed():
	_mark_button("walk_left")

func _right_pressed():
	_mark_button("walk_right")

func _jump_pressed():
	_mark_button("jump")

func _dash_pressed():
	_mark_button("dash")

func _mark_button(string):
	can_change_key = true
	action_string = string
			
	for j in ACTIONS:
		if j != string:
			get_node("Panel/" + str(j) + "/Button").set_pressed(false)
			
func _input(event):
	if event is InputEventKey: 
		if can_change_key and event.scancode != KEY_ENTER:
			_change_key(event)
			for j in ACTIONS:
				get_node("Panel/" + str(j) + "/Button").set_pressed(false)
			can_change_key = false
			
func _change_key(new_key):
	#Delete key of pressed button
	if !InputMap.get_action_list(action_string).empty():
		InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[0])
	
	#Check if new key was assigned somewhere
	for i in ACTIONS:
		if InputMap.action_has_event(i, new_key):
			InputMap.action_erase_event(i, new_key)
			
	#Add new Key
	InputMap.action_add_event(action_string, new_key)
	
	current_keybinds[action_string] = new_key.scancode
	Globals.keybinds = current_keybinds.duplicate()
	Globals.set_game_binds()
	Globals.write_config()
	
	for j in ACTIONS:
		get_node("Panel/" + str(j) + "/Button").set_pressed(false)
	
	_set_keys()
