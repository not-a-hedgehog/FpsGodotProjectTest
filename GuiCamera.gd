extends Camera3D
@onready var camera := $"../../../Neck";

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform = camera.global_transform;
