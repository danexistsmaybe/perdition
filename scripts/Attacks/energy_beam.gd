extends Line2D

var queue : Array

var life_counter := 0

@export var MAX_SIZE := 50
@export var LIFETIME := 60*5

@export var direction : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_points()
	for point in queue:
		add_point(point)

func _physics_process(_delta):
	life_counter += 1

	queue.push_front(Vector2(.05*direction*4**(.05*life_counter), 0) + 4*(.995**life_counter)*Vector2(randf()-.5,randf()-.5))

	if queue.size() > MAX_SIZE:
		queue.pop_back()

	if life_counter >= LIFETIME:
		clear_points()
		queue_free()
