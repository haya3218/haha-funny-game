# Player script. Handles basic movement tactics, as well as some other stuff (like reloading levels)
# All actual updates for the movement is in MainSM.gd, which is the player's StateMachine.
extends KinematicBody2D
class_name Player

# Signals.
signal health_updated(health)
signal killed()

# Main speed variables.
export (int) var speed = 1000
var jump_speed
var gravity
export (Vector2) var wall_jump_velocity = Vector2(400, -400)

# Our velocity.
var velocity = Vector2.ZERO

# Kinematic friction.
export (float, 0, 1.0) var friction = 0.05
export (float, 0, 1.0) var acceleration = 0.1
export (float, 0, 1.0) var speed_acceleration = 0.03

# Jump and walk checks.
var is_jumping = false
var is_grounded = false
var walking = false

# Node Shortcuts.
onready var sprite = $AnimatedSprite
onready var mainSM = $StateMachine
onready var raycasts_left = $Left
onready var raycasts_right = $Right
onready var wscooldown = $WallSlideCooldown
onready var coyote_timer = $CoyoteTime
onready var dash_timer = $DashTime
onready var effects = $AnimationPlayer
onready var invulnerability_timer = $InvulTimer
onready var death_timer = $DeathTimer
onready var sound_player : AudioStreamPlayer2D = $Sounds
onready var wall_timer = $WallSlideStickyTimer

# Move directions.
var move_direction = 0
var wall_direction = 0

# For coyote time.
var was_on_floor = false

# Dashing.
export (int) var dash_speed = 1000 
export (float, 0, 1.0) var dash_length = 0.2
var is_dashing : bool = false # check if we're dashing
var can_dash : bool = true # check if we can dash? 
var dash_direction : Vector2 # get the direction we'll dash in
export (float) var jump_length = 0.4

# Health.
export (float) var max_health = 100
onready var health = max_health setget _set_health

var jump_height = 2.25 * Globals.tile_size

func _ready():
	Globals.player_health = 100
	Globals.current_bar_val = 100
	# get_tree().current_scene.filename can crash the game at points, so get parent's filename instead.
	# Because of this, a level's player must not have a normal parent. It has to be the main level's parent node.
	Globals.current_scene = get_parent().filename
	# Connect dash timer to timeout function.
	dash_timer.connect("timeout",self,"dash_timer_timeout")
	invulnerability_timer.connect("timeout",self,"invul_timeout")
	death_timer.connect("timeout",self,"_reset")
	# Set gravity relative to jump length.
	gravity = 2 * jump_height / pow(jump_length, 2)
	Globals.level_gravity = gravity
	jump_speed = -sqrt(2 * gravity * jump_height)
	# Reset effects.
	effects.play("None")

# Update our move dir.
func _update_move_direction():
	if Input.is_action_pressed("walk_right"):
		move_direction = 1
	elif Input.is_action_pressed("walk_left"):
		move_direction = -1
	else:
		move_direction = 0
	# Don't change our sprite's dir when our move dir is zero.
	if move_direction != 0:
		sprite.scale.x = move_direction * 0.25
		
func get_direction_from_input():
	var move_dir = Vector2()
	move_dir.x = -Input.get_action_strength("walk_left") + Input.get_action_strength("walk_right")
	move_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("jump")
		
	move_dir = move_dir.clamped(1)
	
	#check if no movement is pressed further enough... then dash towards ur facing position
	if (move_dir == Vector2(0,0)):
		move_dir.x = move_direction
			
	return move_dir * dash_speed

# Get our input and change our velocity's x axis
func _get_input():
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * speed, speed_acceleration)
		walking = true
	else:
		velocity.x = lerp(velocity.x, 0, friction)
		walking = false
	
# Handle jumping. Ground checks are in MainSM.gd
func _handle_jump():
	if Input.is_action_pressed("jump") || !coyote_timer.is_stopped():
		velocity.y = jump_speed
		coyote_timer.stop()
		
# Handle wall jumping.
func _wall_jump():
	var wjv = wall_jump_velocity
	wjv.x *= -wall_direction
	velocity = wjv
	
# Handle hurt bounce off.
func _hurt():
	var wjv = wall_jump_velocity
	wjv.x *= -move_direction
	velocity = wjv
		
# Apply gravity.
func _apply_gravity(delta):
	if coyote_timer.is_stopped():
		velocity.y += gravity * delta
	
# Wall slide gravity.
func _cap_gravity_wall_slide():
	var max_velocity = 32 if !Input.is_action_pressed("ui_down") else 6 * 32
	velocity.y = min(velocity.y, max_velocity)
		
# Just for reloading current level, and other stuff.
func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		_reset()
	if Globals.player_health < 1:
		sprite.scale.x = lerp(sprite.scale.x, 1, 0.1)
		sprite.scale.y = lerp(sprite.scale.y, 0, 0.1)
	if Globals.player_health < 1 and mainSM.state != mainSM.states.death:
		death_timer.start()
		_kill()

func _reset():
	Transitions.slide_rect2(self, Globals.current_scene, 2, Color.black, Vector2(-2, 0))
			
# Finalize our movement.
func _finalize_movement(delta):
	var snap = Vector2.DOWN * (Globals.tile_size / 8) if !is_jumping else Vector2.ZERO
	was_on_floor = is_on_floor()
	if !is_dashing:
		velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP)
	else:
		velocity = move_and_slide(dash_direction, Vector2.UP)
	
# Update our wall dir.
func _update_wall_direction():
	var isleft = _check_is_valid_wall(raycasts_left)
	var isright = _check_is_valid_wall(raycasts_right)
	
	if isleft and isright:
		wall_direction = move_direction
	else:
		wall_direction = -int(isleft) + int(isright)
	
# Check if a raycast is a valid wall.
func _check_is_valid_wall(raycast):
	if raycast is RayCast2D:
		if raycast.is_colliding() and not raycast.get_collider().is_in_group("unwallable"):
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
					return true
	return false
	
func handle_dash(delta):
	if(Input.is_action_just_pressed("dash") and can_dash and is_jumping):
		is_dashing = true
		can_dash = false
		dash_direction = get_direction_from_input()
		dash_timer.start(dash_length)
		sound_player.stream = load("res://Sounds/Dash.wav")
		sound_player.play()
	
# Shorter function for get_node lmao
func gn(node):
	return get_node(node)
	
func dash_timer_timeout():
	is_dashing = false
	
func _kill():
	mainSM.set_state(mainSM.states.death)
	
func damage():
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - Globals.player_dmg)
		effects.play("Damage")
		effects.queue("Flash")
		sprite.play("Hurt")
		mainSM.set_state(mainSM.states.hurt)

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	Globals.player_health = health
	print(Globals.player_health)
	if Globals.player_health < 1:
		_kill()
	if health != prev_health:
		emit_signal("health_updated", health)
			
func invul_timeout():
	effects.play("None")
	
func _handle_wall_slide():
	pass
