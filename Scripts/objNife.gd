extends CharacterBody3D

var velo = Vector3();
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			collision.get_collider().apply_impulse(-Vector3(sin(rotation.y),rotation.x,cos(rotation.y)).normalized()*2)
			get_parent().queue_free();
	
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	move_and_slide()
