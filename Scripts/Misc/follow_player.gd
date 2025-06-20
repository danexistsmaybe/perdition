extends Node2D

func _physics_process(_delta):
	position = GlobalBus.get_player_reference().position
