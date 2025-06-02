extends Node2D

@export var Segment : PackedScene

@export var START_SEGMENTS := 3

var segments := []
var head : Node2D
var tail : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	head = Segment.instantiate()
	head.sprite_id = 0
	head.position = position
	add_child(head)

	for i in range(START_SEGMENTS):
		var segment = Segment.instantiate()
		segment.sprite_id = [4,8][randi()%2]
		segment.position = position + Vector2(16*(i+1), 0)
		segments.append(segment)
		add_child(segment)
	tail = Segment.instantiate()
	tail.sprite_id = 12
	tail.position = position + Vector2(16*(START_SEGMENTS+1), 0)
	add_child(tail)
	segments.append(tail)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(_delta):
	position.x -= .4
