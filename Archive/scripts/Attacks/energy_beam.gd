extends Line2D

var queue : Array

var life_counter := 0

@export var MAX_SIZE := 50
@export var LIFETIME := 60*3

@export var direction : Vector2
@export var start_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$sparks.emitting = false
	queue.push_front(start_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_points()
	for point in queue:
		add_point(point)

func _physics_process(_delta):
	life_counter += 1
	if life_counter < LIFETIME:

		queue.push_front(start_position + Vector2(.05*direction.x*4**(.05*life_counter), 0) + 4*(.995**life_counter)*Vector2(randf()-.5,randf()-.5))

		if queue.size() > MAX_SIZE:
			queue.pop_back()

		if len(queue) > 1: detect_collision()
	if life_counter >= LIFETIME:
		queue.clear()
		$sparks.emitting = false
	if life_counter >= LIFETIME + 60:
		clear_points()
		queue_free()
 
func detect_collision():
	var space_state = get_world_2d().direct_space_state

	var result = space_state.intersect_ray( PhysicsRayQueryParameters2D.create(queue[1],queue[0], 0b10010) )
	if result: 
		queue[0] = result.position - .1*(result.position - queue[1]).normalized()
		var reverse = -1*(result.position - queue[1]).normalized()
		$sparks.position = queue[0]
		$sparks.process_material.direction = Vector3(reverse.x,reverse.y,0)
		$sparks.emitting = true
		if (queue[-1] - queue[0]).length() < 1: 
			$sparks.emitting = false
	else:
		$sparks.emitting = false

