extends RigidBody2D
class_name Machete

signal clicked
var held = false
var lmao = false

func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()
		rotation_degrees = lerp(rotation_degrees, 0, 0.1)
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			$AnimatedSprite.play("Swing")
	if $AnimatedSprite.animation == "Swing" and $AnimatedSprite.frame > 8:
		$AnimatedSprite.play("Rebound")
	if $AnimatedSprite.animation == "Rebound" and $AnimatedSprite.frame > 10:
		$AnimatedSprite.play("Idle")
func pickup():
	if held:
		return
	mode = RigidBody2D.MODE_STATIC
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		mode = RigidBody2D.MODE_RIGID
		apply_central_impulse(impulse)
		held = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

func _mouse_entered():
	lmao = true
	print(lmao)

func _mouse_exited():
	lmao = false
	print(lmao)

func _body_entered(body):
	if body != null and held:
		if body is Enemy:
			if $AnimatedSprite.animation == "Swing" and not body.hurt:
				print('ye')
				if !body.dead:
					Globals.current_bar_val += 5
					body.damage()
