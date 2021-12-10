# Global variables.
extends Node

var current_scene = "" # Current scene. Set by the player.
var tile_size = 32 # Tile size.
var level_gravity = 0 # Level gravity.
var player_dmg = 0.333333333*100 # Equivalent to 3 hearts.
var player_health = 100 # Current player health.
var current_bar_val = 100 # Current skate var value.
var current_level = 1

export var max_load_time = 10000 # Max load time for loading.
onready var menuSound = preload("res://Sounds/Menu.wav")

# Keybinding shit
var filepath = OS.get_executable_path().get_base_dir() + "/keybinds.ini"
var configfile

var keybinds = {}

var exited_options = true
# Go to a specific scene in the most obtuse way.
# This also properly does loading scenes between two scenes with a loading bar.
# Doesn't use threads because threads suck
func goto_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Resource loader unable to load the resource at path")
		return
	
	var loading_bar = load("res://Objects/UI/LoadingScene.tscn").instance()
	
	get_tree().get_root().call_deferred('add_child',loading_bar)
	
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() - t < max_load_time:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			#Loading Complete
			var resource = loader.get_resource()
			# Instantiate new scene.
			var new_scene = resource.instance()
			# Free current scene.
			get_tree().current_scene.free()
			get_tree().current_scene = null
			# Add new one to root.
			get_tree().root.add_child(new_scene)
			# Set as current scene.
			get_tree().current_scene = new_scene
			loading_bar.queue_free()
			break
		elif err == OK:
			#Still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_bar.get_node("LoadingBar").value = progress * 100
			print(progress*100)
		else:
			print("Error while loading file")
			break
		yield(get_tree(),"idle_frame")
		
func _ready():
	configfile = ConfigFile.new()
	print("LOADING KEYBINDS")
	if configfile.load(filepath) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var key_value = configfile.get_value("keybinds", key)
			
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	else:
		print("CONFIG FILE NOT FOUND")
		print("CREATING ONE INSTEAD")
		configfile.set_value("keybinds", "walk_left", KEY_A)
		configfile.set_value("keybinds", "walk_right", KEY_D)
		configfile.set_value("keybinds", "jump", KEY_W)
		configfile.set_value("keybinds", "dash", KEY_X)
		configfile.save(filepath)
		print("LOADING KEYBINDS")
		if configfile.load(filepath) == OK:
			for key in configfile.get_section_keys("keybinds"):
				var key_value = configfile.get_value("keybinds", key)
				
				if str(key_value) != "":
					keybinds[key] = key_value
				else:
					keybinds[key] = null
		else:
			print('COULD NOT READ KEYBINDS')
	
	set_game_binds()

func set_game_binds():
	print(keybinds)
	for key in keybinds.keys():
		var value = keybinds[key]
		
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key, actionlist[0])
		
		if value != null:
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)
			InputMap.action_add_event(key, new_key)

func write_config():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configfile.set_value("keybinds", key, key_value)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(filepath)
