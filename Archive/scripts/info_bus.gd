extends Node2D

var player_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_player_pos(pos):
	player_pos = pos

func get_player_pos():
	return player_pos