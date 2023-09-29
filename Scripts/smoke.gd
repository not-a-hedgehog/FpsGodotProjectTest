extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 1 * delta
	
	velocity.x *= 0.99;
	velocity.z *= 0.99;
	
	move_and_slide()
