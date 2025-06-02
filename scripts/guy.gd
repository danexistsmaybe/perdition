extends CharacterBody2D


@onready var animator : AnimationPlayer = $AnimationPlayer 

# Attacks
@export var EnergyBeam : PackedScene


# Stats
var run_speed = 90

# Machinery
var timers := {}

enum States {
	GROUNDED,
	SLIDING,
	AIRBORNE,
	CLIMBING
}
var state : States

var last_position : Vector2 = Vector2(0,0)

# Animation / Visuals
enum AnimationStates {
	IDLE,
	RUNNING_LEFT,
	RUNNING_RIGHT,
	SLIDING_LEFT,
	SLIDING_RIGHT,
	JUMPING_LEFT,
	JUMPING_RIGHT,
	FALLING_LEFT,
	FALLING_RIGHT
}
var animation_state : AnimationStates
var animation_queue : String



# Physics
var acceleration := Vector2(0,0)
var friction := Vector2(0,0)
var gravity := Vector2(0,9.8)
var dampner := Vector2(0,0)
var damp_jerk : float = 0

var friction_coefficient := {
	States.GROUNDED: 1,
	States.SLIDING: .9,
	States.AIRBORNE: .01
}


func _ready():
	set_state(States.GROUNDED)
	set_animation_state(AnimationStates.IDLE)
	animator.animation_finished.connect(_on_animation_finished)


func _process(_delta):
	process_animation_state()

func _physics_process(_delta):
	#print(velocity)
	process_state()
	process_physics()
	for timer in timers: 
		timers[timer] -= 1
	InfoBus.set_player_pos(position)


func process_state():
	if state == States.GROUNDED:
		if Input.is_action_pressed("left"):
			velocity.x = max(velocity.x - 12, -1*run_speed)
			set_animation_state(AnimationStates.RUNNING_LEFT)
		elif Input.is_action_pressed("right"):
			velocity.x = min(velocity.x + 12, run_speed)
			set_animation_state(AnimationStates.RUNNING_RIGHT)
		
		if check_timer("jump"):
			velocity.y -= 600
			dampner.y += 60
			damp_jerk = .85
			set_state(States.AIRBORNE)
			rm_timer("jump")
			return
		if Input.is_action_pressed("up") and check_timer("jump", true):
			if velocity.x > 0:
				set_animation_state(AnimationStates.JUMPING_RIGHT)
			else:
				set_animation_state(AnimationStates.JUMPING_LEFT)
			set_timer("jump", 15)


		if Input.is_action_pressed("attack") and abs(velocity.x) > 5 and check_timer("attack_cooldown", true):
			set_timer("attack_cooldown", 60)
			set_state(States.SLIDING)
			set_animation_state(AnimationStates.SLIDING_LEFT if get_direction() == 1 else AnimationStates.SLIDING_RIGHT)
			for i in range(8):
				var beam = EnergyBeam.instantiate() as Node2D
				beam.direction = Vector2(get_direction(), 0)
				beam.position = Vector2(0,0)
				beam.start_position = position + Vector2(4*get_direction(), 10*randf() - 5)
				add_sibling(beam)
			velocity.x = velocity.x + (800 if velocity.x < 0 else -800)
		
		if not is_on_floor():
			rm_timer("jump")
			set_state(States.AIRBORNE)

		last_position = position
	
	elif state == States.SLIDING:
		if ((Input.is_action_pressed("left") or Input.is_action_pressed("right")) and abs(velocity.x) < run_speed - 10) or abs(velocity.x) < 8:
			set_state(States.GROUNDED)
			if Input.is_action_pressed("right"):
				set_animation_state(AnimationStates.RUNNING_RIGHT)
			elif Input.is_action_pressed("left"):
				set_animation_state(AnimationStates.RUNNING_LEFT)
			else:
				set_animation_state(AnimationStates.IDLE)
	
	elif state == States.AIRBORNE:
		if is_on_floor():
			set_state(States.GROUNDED)
			return

		if Input.is_action_pressed("left"):
			velocity.x = max(velocity.x - 12, -1*run_speed)
			if not animation_state in [AnimationStates.SLIDING_LEFT, AnimationStates.SLIDING_RIGHT]:
				set_animation_state(AnimationStates.FALLING_LEFT)
		elif Input.is_action_pressed("right"):
			velocity.x = min(velocity.x + 12, run_speed)
			if not animation_state in [AnimationStates.SLIDING_LEFT, AnimationStates.SLIDING_RIGHT]:
				set_animation_state(AnimationStates.FALLING_RIGHT)

		if Input.is_action_pressed("attack") and abs(velocity.x) > 5 and check_timer("attack_cooldown", true):
			set_timer("attack_cooldown", 60)
			set_animation_state(AnimationStates.SLIDING_LEFT if get_direction() == 1 else AnimationStates.SLIDING_RIGHT)
			for i in range(8):
				var beam = EnergyBeam.instantiate() as Node2D
				beam.direction = Vector2(get_direction(), 0)
				beam.position = Vector2(0,0)
				beam.start_position = position + Vector2(4*get_direction(), 10*randf() - 5)
				add_sibling(beam)
			velocity.x = velocity.x + (800 if velocity.x < 0 else -800)

		last_position = position


func process_physics():
	#print(velocity)
	# act on velocity
	move_and_slide()

	# act on acceleration
	velocity += acceleration

	# calculate nwew acceleration
	friction.x = -.015*max(gravity.y, 0)*velocity.x * friction_coefficient[state]
	dampner = Vector2(-1*abs(dampner.x)*sign(velocity.x),-1*abs(dampner.y)*sign(velocity.y))
	acceleration = friction + gravity + dampner

	dampner *= damp_jerk

func set_state(_state):
	var prev_state = state
	state = _state

	if state in [States.AIRBORNE, States.GROUNDED]:
		last_position = position

	if state == States.GROUNDED and prev_state == States.AIRBORNE:
		set_animation_state(AnimationStates.IDLE)
		dampner.x += 100
		damp_jerk = .9

# ================================== TIMER =============================================

func set_timer(name, value):
	timers[name] = value

func check_timer(name, read_null_as = false) -> bool:
	if timers.get(name) == null:
		return read_null_as
	if timers.get(name) < 1:
		return true
	return false

func rm_timer(name):
	timers.erase(name)



# ===================================== ANIMATION ===========================================

func process_animation_state():
	if animation_state in [AnimationStates.RUNNING_LEFT,AnimationStates.RUNNING_RIGHT] and abs(velocity.x) < 5:
		set_animation_state(AnimationStates.IDLE)

	if animation_state in [AnimationStates.SLIDING_LEFT, AnimationStates.SLIDING_RIGHT] and state == States.AIRBORNE:
		if (abs(velocity.x) < run_speed - 10) or abs(velocity.x) < 8:
			if velocity.x < 0:
				set_animation_state(AnimationStates.FALLING_LEFT)
			else:
				set_animation_state(AnimationStates.FALLING_RIGHT)

	if animation_state == AnimationStates.IDLE and check_timer("idle"):
		animator.play("idle_dance")
		rm_timer("idle")
		


func set_animation_state(_animation_state : AnimationStates):
	#print(animation_state, "to", _animation_state)
	if _animation_state == animation_state: 
		return
	var prev_state = animation_state
	animation_state = _animation_state

	if animation_state == AnimationStates.RUNNING_LEFT:
		if prev_state == AnimationStates.IDLE:
			animator.play("turn_left")
			animation_queue = "run_left"
		elif prev_state == AnimationStates.RUNNING_RIGHT:
			animation_state = AnimationStates.IDLE
			animator.play_backwards("turn_right")
			animation_queue = "turn_left"
		elif prev_state == AnimationStates.SLIDING_LEFT:
			animator.play("turn_left")
			animation_queue = "run_left"
		elif prev_state == AnimationStates.SLIDING_RIGHT:
			animator.play("run_left")
		else:
			animation_state = prev_state
	elif animation_state == AnimationStates.RUNNING_RIGHT:
		if prev_state == AnimationStates.IDLE:
			animator.play("turn_right")
			animation_queue = "run_right"
		elif prev_state == AnimationStates.RUNNING_LEFT:
			animation_state = AnimationStates.IDLE
			animator.play_backwards("turn_left")
			animation_queue = "turn_right"
		elif prev_state == AnimationStates.SLIDING_LEFT:
			animator.play("run_right")
		elif prev_state == AnimationStates.SLIDING_RIGHT:
			animator.play("turn_right")
			animation_queue = "run_right"
		else:
			animation_state = prev_state
	elif animation_state == AnimationStates.IDLE:
		if prev_state == AnimationStates.RUNNING_RIGHT:
			animator.play_backwards("turn_right")
			animation_queue = "idle"
		elif prev_state == AnimationStates.RUNNING_LEFT:
			animator.play_backwards("turn_left")
			animation_queue = "idle"
		elif prev_state in [AnimationStates.JUMPING_RIGHT, AnimationStates.FALLING_RIGHT]:
			animator.play("land_right")
			animation_queue = "idle"
		elif prev_state in [AnimationStates.JUMPING_LEFT, AnimationStates.FALLING_LEFT]:
			animator.play("land_left")
			animation_queue = "idle"
		else:
			animator.play("idle")

		set_timer("idle", 600)
	elif animation_state == AnimationStates.SLIDING_RIGHT:
		animator.play("slide_right")
	elif animation_state == AnimationStates.SLIDING_LEFT:
		animator.play("slide_left")
	elif animation_state == AnimationStates.JUMPING_RIGHT:
		animator.play("jump_right")
	elif animation_state == AnimationStates.JUMPING_LEFT:
		animator.play("jump_left")
	elif animation_state == AnimationStates.FALLING_RIGHT:
		animator.stop()
		$spritesheet.frame = 43
	elif animation_state == AnimationStates.FALLING_LEFT:
		animator.stop()
		$spritesheet.frame = 44


func _on_animation_finished(name):
	animator.play(animation_queue)
	animation_queue = ""
	
	#animator.playback_speed = 1



# ================================== CONVENIENCE =======================================
func get_direction():
	return 1 if velocity.x > 0 else -1