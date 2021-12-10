extends "res://Scripts/StateMachine.gd"

func _ready():
	add_state("walk")
	add_state("hurt")
	add_state("dead")
	call_deferred("set_state", states.walk)

func _state_logic(delta):
	if parent is Enemy:
		if parent.health < 1:
			set_state("dead")
			parent.velocity.x = 0
			parent._apply_gravity(delta)
			parent._finalize_movement(delta)
			parent.dead = true
			parent.sprite.play("Death")
			if parent.sprite.frame < 1:
				var soundass = AudioStreamPlayer2D.new()
				soundass.stream = load("res://Sounds/Death.wav")
				get_tree().get_root().add_child(soundass)
				soundass.play()
			if !parent.sprite.is_playing():
				parent.queue_free()
		else:
			if parent.sprite.animation != 'Hurt':
				parent._move_bitch(delta)
			parent._apply_gravity(delta)
			parent._finalize_movement(delta)
			if state == states.hurt:
				parent.sprite.play("Hurt")
				if parent.sprite.animation == 'Hurt' and parent.sprite.frame > 5:
					set_state("Walk")
			if state == states.hurt and !parent.hurt:
				parent.velocity = 0
				parent._hurt()
				parent.sound.stream = load("res://Sounds/Hit.wav")
				parent.sound.play()
				parent.hurt = true
				parent._apply_gravity(delta)
				parent._finalize_movement(delta)
				
	
func _get_transition(delta):
	if parent is Enemy:
		match state:
			states.walk:
				parent.sprite.play("Walk")
				parent.hurt = false
				return states.walk
			states.hurt:
				parent.sprite.play("Hurt")
				if parent.sprite.animation == 'Hurt' and (parent.is_on_floor() or parent.is_on_ceiling()):
					parent.hurt = false
					return states.walk
				else:
					return states.hurt
			states.dead:
				return states.dead
	return null
	
func _enter_state(new_state, old_state):
	if parent is Enemy:
		match new_state:
			states.walk:
				# parent.sprite.play("Walk")
				print('no')
			states.hurt:
				parent.sprite.play("Hurt")
			states.dead:
				parent.sprite.play("Death")
	
func _exit_state(old_state, new_state):
	pass


func _on_AnimatedSprite_animation_finished():
	if parent.sprite.animation == "Death":
		parent.queue_free()
