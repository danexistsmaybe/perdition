extends Node2D

var last_press := 0

func _physics_process(_delta):
	if last_press > 15 and Input.is_action_pressed("debug"):
		debug()


	last_press += 1


func debug():
	# do whatever
	change_viewport_dimensions()

func change_viewport_dimensions():
	DisplayServer.window_set_size(Vector2i(800,600))