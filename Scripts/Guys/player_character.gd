extends CharacterBody2D



# references

# some stats
var walk_speed := 70

# machinery
var timers := {}

enum AnimationStates {
	IDLE,
	WALKING
}

var true_position : Vector2
var direction = Vector2(0,1)



func _ready():
	GlobalBus.set_player_reference(self)
	true_position = position

func _process(_delta):
	position = Vector2(round(true_position.x), round(true_position.y))

func _physics_process(_delta):
	process_controls()
	process_physics()
	process_timers()

func process_controls():
	if GlobalBus.dialoguing:
		set_timer("interaction", 3)
		return
	# movement
	var control_vector = Vector2(0,0)
	if Input.is_action_pressed("left"):
		control_vector.x -= 1
	if Input.is_action_pressed("right"):
		control_vector.x += 1
	if Input.is_action_pressed("up"):
		control_vector.y -= 1
	if Input.is_action_pressed("down"):
		control_vector.y += 1
	control_vector = control_vector.normalized()
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		velocity += walk_speed*control_vector
		set_direction(control_vector)

	# interaction
	if Input.is_action_just_pressed("a") and check_timer("interaction", true):
		attempt_interact()



func process_physics():
	move_and_slide()

	# think of it like infinite friction...
	velocity = Vector2(0,0)

func set_direction(dir):
	direction = dir
	$InteractionZone.position = 5*dir

func attempt_interact():
	var candidates = $InteractionZone.get_overlapping_areas() + $InteractionZone.get_overlapping_bodies()
	if len(candidates)>0:
		for candidate in candidates:
			# attempt dialogue
			if GlobalBus.get_dialogue_reference().attempt_dialogue(candidate):
				return

			# attempt interact
			if candidate.has_method("interact"):
				candidate.interact()
				return

# TODO:
	# Do everything in other nodes, hook dialogue up
	# WHAT ABOUT THE TEXT SYSTEM ????????
		# it will have to attempt to talk first I think for ease of adding text


# ================================== TIMER =============================================

func set_timer(_name, value):
	timers[_name] = value

func check_timer(_name, read_null_as = false) -> bool:
	if timers.get(_name) == null:
		return read_null_as
	if timers.get(_name) < 1:
		return true
	return false

func rm_timer(_name):
	timers.erase(_name)

func process_timers():
	for timer in timers:
		timers[timer] -= 1
