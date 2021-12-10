extends KinematicBody2D
class_name Enemy

# Signals.
signal health_updated(health)
signal killed()

# Health.
export (float) var max_health = 100
onready var health = max_health
var speed = Globals.tile_size * 64
var move_direction = 1

var velocity = Vector2()

var hurt = false
var dead = false

onready var sprite : AnimatedSprite = $AnimatedSprite
onready var mainSM = $StateMachine
onready var invulnerability_timer = $InvulTimer
onready var sound = $Sounds

# Apply gravity.
func _apply_gravity(delta):
	velocity.y += Globals.level_gravity * delta

func _move_bitch(delta):
	velocity.x = speed * move_direction * delta
	sprite.scale.x = move_direction * -1 * 0.25
		
# Handle hurt bounce off.
func _hurt():
	var wjv = Vector2(400, -400)
	wjv.x *= -move_direction
	velocity = wjv

# Finalize our movement.
func _finalize_movement(delta):
	velocity = move_and_slide(velocity, Vector2.UP)

func _body_entered(body):
	if not body.is_in_group("pickable"):
		move_direction *= -1
		sprite.scale.x = move_direction * -1 * 0.25
		if body is Player:
			body.damage()
		
func _kill():
	mainSM.set_state(mainSM.states.dead)
	
func damage():
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - Globals.player_dmg)
		mainSM.set_state(mainSM.states.hurt)
		_hurt()

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health < 1:
		_kill()
	if health != prev_health:
		emit_signal("health_updated", health)
		
func _physics_process(delta):
	if hurt:
		sprite.play("Hurt")
