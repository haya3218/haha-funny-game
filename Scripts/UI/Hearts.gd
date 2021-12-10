extends Node2D

onready var heart_array = [$Heart1/AnimationPlayer, $Heart2/AnimationPlayer, $Heart3/AnimationPlayer]
var deactivated_hearts = [false, false, false]

func _process(delta):
	_change_health()

func _change_health():
	if Globals.player_health < 1:
		if not deactivated_hearts[0]:
			heart_array[0].play("Remove")
		if not deactivated_hearts[1]:
			heart_array[1].play("Remove")
		if not deactivated_hearts[2]:
			heart_array[2].play("Remove")
		deactivated_hearts[0] = true
		deactivated_hearts[1] = true
		deactivated_hearts[2] = true
	elif Globals.player_health < 34:
		heart_array[0].play("Nothing")
		if not deactivated_hearts[1]:
			heart_array[1].play("Remove")
		if not deactivated_hearts[2]:
			heart_array[2].play("Remove")
		deactivated_hearts[0] = false
		deactivated_hearts[1] = true
		deactivated_hearts[2] = true
	elif Globals.player_health < 67:
		heart_array[0].play("Nothing")
		heart_array[1].play("Nothing")
		if not deactivated_hearts[2]:
			heart_array[2].play("Remove")
		deactivated_hearts[0] = false
		deactivated_hearts[1] = false
		deactivated_hearts[2] = true
	else:
		for heart_ani in heart_array:
			heart_ani.play("Nothing")
		for deactivated_heart in deactivated_hearts:
			deactivated_heart = false
			
