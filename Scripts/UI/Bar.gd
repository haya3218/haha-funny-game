extends Node2D

onready var main_bar : TextureProgress = $SkateBar
onready var tweened_bar : TextureProgress = $AfterBar
onready var tween : Tween = $Tween

export (float, 0, 1.0) var tween_duration = 0.4

var current_value = 100

export (Color) var healthy_color = Color.greenyellow
export (Color) var mild_color = Color.orange
export (Color) var oh_noes_color = Color.red
export (float) var mild_progress = 0.5
export (float) var oh_noes_progress = 0.3

func _ready():
	main_bar.value = 100
	tweened_bar.value = 100

func _process(delta):
	Globals.current_bar_val = clamp(Globals.current_bar_val - 0.04, 0, 100)
	main_bar.value = Globals.current_bar_val

func _on_SkateBar_value_changed(value):
	if value < main_bar.max_value * oh_noes_progress:
		main_bar.tint_progress = oh_noes_color
		tweened_bar.tint_progress = oh_noes_color
		tweened_bar.tint_progress.v -= 0.3
	elif value < main_bar.max_value * mild_progress:
		main_bar.tint_progress = mild_color
		tweened_bar.tint_progress = mild_color
	else:
		main_bar.tint_progress = healthy_color
		tweened_bar.tint_progress = healthy_color
		tweened_bar.tint_progress.v -= 0.3
	tween.interpolate_property(tweened_bar, "value", tweened_bar.value, main_bar.value, tween_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
