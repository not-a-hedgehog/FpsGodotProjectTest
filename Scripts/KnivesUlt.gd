extends Node3D

var facas = [true,true,true,true,true];

var facaId : int = 0;

func reload():
	facas = [true,true,true,true,true];
	facaId = 0;

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("fire") and facaId < facas.size() and visible:
		facas[facaId] = false;
		facaId+=1;
	var _j = 0;
	for i in get_children():
		i.rotation.z += deg_to_rad(10);
		i.visible = facas[_j]
		_j+=1;
	
