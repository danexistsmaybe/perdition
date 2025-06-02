extends CharacterBody2D

var angular_velocity := 0.0
var bounce := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(_delta):
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		velocity += Vector2(velocity.normalized().y, velocity.normalized().x)
		angular_velocity *= .5

	var result = get_world_2d().direct_space_state.intersect_ray( PhysicsRayQueryParameters2D.create(position, InfoBus.get_player_pos(), 0b10000) )
	if result:
		pass
	else:
		velocity += .1*(InfoBus.get_player_pos() - position).normalized()
 
	velocity *= .99

	rotation += angular_velocity

	angular_velocity -= PI/256

func _on_body_entered(body):
	bounce = true