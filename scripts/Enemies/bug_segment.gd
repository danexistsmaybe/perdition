extends Node2D

var sprite_id : int
var current_sprite : int

# Called when the node enters the scene tree for the first time.
func _ready():
	current_sprite = sprite_id


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite2D.frame = current_sprite

func _physics_process(_delta):
	if randi()%12==0: 
		current_sprite = sprite_id + randi()%4