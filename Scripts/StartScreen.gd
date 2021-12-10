extends Control

func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	Transitions.slide_rect(self, "res://Scenes/TitleScreen.tscn", 2, Color.black, Vector2(-2, 0))
