extends Node2D

var held_object = null

func _ready():
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("clicked", self, "_on_pickable_clicked")

func _on_pickable_clicked(object):
	if !held_object:
		held_object = object
		held_object.pickup()
		
func _process(delta):
	if held_object and !Input.is_action_pressed("clicc"):
		print('yes 2')
		held_object.drop(Input.get_last_mouse_speed())
		held_object = null
	pass
