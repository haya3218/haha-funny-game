# Player's state machine. From https://www.youtube.com/watch?v=j_pM3CiQwts
# This exists to make shit less convoluted.
# I ain't explainin what this does in detail. Go figure it out yourself :trolleybus:
extends "res://Scripts/StateMachine.gd"

# Add our states.
func _ready():
	# Adds all of our states.
	# Hurt and Death are barely implemented yet; I'll go do that later
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	add_state("hurt")
	add_state("death")
	# Call "set_state" passing in the parameter of our idle state.
	call_deferred("set_state", states.idle)
	
# Call whenever an input is pressed.
func _input(event):
	if state != states.death:
		if state == states.wall_slide && Input.is_action_pressed("jump"):
			parent._wall_jump()
			parent.is_jumping = true
			parent.is_grounded = !parent.is_jumping
			set_state(states.jump)
		elif state == states.jump:
			parent.is_jumping = true
			parent.is_grounded = !parent.is_jumping
	
# Handle our actual movement.
func _state_logic(delta):
	if state != states.death:
		parent._update_move_direction()
		parent._update_wall_direction()
		parent.handle_dash(delta)
		parent._get_input()
		if [states.run, states.idle].has(state):
			parent._handle_jump()
			parent.is_jumping = false
			parent.is_grounded = !parent.is_jumping
		parent._apply_gravity(delta)
		if state == states.wall_slide:
			if parent.wall_direction != 0:
				parent.sprite.scale.x = -parent.wall_direction * 0.25
			parent._cap_gravity_wall_slide()
			parent._handle_wall_slide()
		parent._finalize_movement(delta)
		if state == states.hurt:
			parent._hurt()
			parent.is_jumping = true
			parent.is_grounded = !parent.is_jumping
			
		if parent.is_on_floor():
			parent.can_dash = true
			
		if Globals.player_health == 0:
			parent._kill()
			set_state(states.death)
	else:
		parent.velocity.x = 0
		parent._apply_gravity(delta)
		parent._finalize_movement(delta)
	
# Handle state transitioning.
func _get_transition(delta):
	if state != states.death:
		match state:
			states.idle:
				if !parent.is_on_floor():
					if parent.velocity.y < 0:
						return states.jump
					elif parent.velocity.y > 0:
						return states.fall
				elif parent.walking:
					return states.run
			states.run:
				if !parent.is_on_floor():
					if parent.velocity.y < 0:
						return states.jump
					elif parent.velocity.y > 0:
						return states.fall
				elif !parent.walking:
					return states.idle
			states.jump:
				if parent.wall_direction != 0 && parent.wscooldown.is_stopped():
					return states.wall_slide
				elif parent.is_on_floor():
					return states.idle
				elif parent.velocity.y >= 0:
					return states.fall
			states.fall:
				if parent.wall_direction != 0 && parent.wscooldown.is_stopped():
					return states.wall_slide
				elif parent.is_on_floor():
					return states.idle
				elif parent.velocity.y < 0:
					return states.jump
			states.wall_slide:
				if parent.is_on_floor():
					return states.idle
				elif parent.wall_direction == 0:
					return states.fall
			states.hurt:
				if !parent.is_on_floor():
					if parent.velocity.y < 0:
						return states.jump
					elif parent.velocity.y > 0:
						return states.fall
				elif !parent.walking:
					return states.idle
				elif parent.walking:
					return states.run
			states.death:
				return states.death
	return null
	
# Handle state entering.
func _enter_state(new_state, old_state):
	if parent is Player:
		var sound = parent.sound_player
		match new_state:
			states.idle:
				if parent.invulnerability_timer.is_stopped():
					parent.sprite.play("Idle")
			states.run:
				if parent.invulnerability_timer.is_stopped():
					parent.sprite.play("Run")
			states.jump:
				if parent.invulnerability_timer.is_stopped():
					parent.sprite.play("Jump")
					sound.stream = load("res://Sounds/Jump.wav")
					sound.play()
			states.fall:
				if parent.invulnerability_timer.is_stopped():
					parent.sprite.play("Fall")
				if !parent.is_on_floor() && parent.was_on_floor:
					parent.coyote_timer.start()
					parent.velocity.y = 0
				print(parent.coyote_timer.is_stopped())
			states.wall_slide:
				if parent.invulnerability_timer.is_stopped():
					parent.sprite.play("Run")
					parent.sprite.scale.x = -parent.wall_direction * 0.25
			states.hurt:
				sound.stream = load("res://Sounds/Ouch.wav")
				sound.play()
			states.death:
				sound.stream = load("res://Sounds/Death_Player.wav")
				sound.play()
				parent.sprite.play("Hurt")
	
# Exit states.
func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wscooldown.start()


func _on_WallSlideStickyTimer_timeout():
	print('trol')
	if state == states.wall_slide:
		set_state(states.fall)
	pass
