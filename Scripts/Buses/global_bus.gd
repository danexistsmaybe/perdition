# This is the script that contains all global variables. I expect it will get pretty long, so
# consider splitting it up and reformatting things as it goes on.
extends Node2D


var player_reference : Node2D
var dialogue_reference : Node2D


var dialoguing : bool = false

func set_player_reference(ref):
	player_reference = ref

func get_player_reference():
	if player_reference: 
		return player_reference
	else:
		return null

func set_dialogue_reference(ref):
	dialogue_reference = ref

func get_dialogue_reference():
	if dialogue_reference: 
		return dialogue_reference
	else:
		return null
