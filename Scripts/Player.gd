extends CharacterBody3D

# Import Nodes

@onready var camera := $CanvasLayer/Neck/Camera3D;
@onready var neck := $CanvasLayer/Neck;
@onready var gun := $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/gun;

@onready var gunAnim := $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/gun/gunAim

@onready var rayCast := $PlayerRay;

@onready var label := $CanvasLayer/Label;

@onready var facas := $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Facas
@onready var dashTimer := $Timer;

# Mouse Settings

@export var MouseSensibility := 0.01;

# Movement

@export var GUN_SWAY_SPEED := 20.0;
@export var GUN_SWAY_MULT := 1.0;

@export var SPEED := 5.0;
@export var JUMP_VELOCITY := 4.5;


var gunSelected = 0;
var gunSwitch = 0;
var smoke = load("res://Objects/SmokeObj.tscn")
var knife = load("res://Objects/faquitaObj.tscn");

@export var bulletForce := 2.0;

@export var strafeCountMax := 2;
var strafeCount := strafeCountMax;

@export var strafeForce := 10;

@export var dashForce = 15.0;

var onDash := false;
var dashCdMax = 60*10;
var dashCd = dashCdMax;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var rot := Vector2(0,0);
var rat := Vector3(0.0,0.0,0.0)

var cam_relative := Vector2.ZERO;
var _pistol_origin_rot := Vector3.ZERO;

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * MouseSensibility);
			camera.rotate_x(-event.relative.y * MouseSensibility);
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-70),deg_to_rad(60))
			cam_relative = event.relative;

func spawnSmoke():
	var _ii = smoke.instantiate();
	var _vec = Vector3(sin(neck.rotation.y+deg_to_rad(180)),camera.rotation.x,cos(neck.rotation.y+deg_to_rad(180)));
	_ii.velocity = _vec.normalized()*5
	_ii.top_level = true;
	add_child(_ii);


func _ready() -> void:

	_pistol_origin_rot = gun.rotation_degrees;

func gunFire():
	gunAnim.play("SHOOT");
	if gunSelected == 1 and facas.facaId < facas.facas.size():
		var fa = knife.instantiate();
		fa.position.y = 1.1;
		var _vec = Vector3(sin(neck.rotation.y+deg_to_rad(180)),camera.rotation.x,cos(neck.rotation.y+deg_to_rad(180)));
		fa.get_child(0).velocity = _vec.normalized()*8;
		fa.get_child(0).rotation.x = camera.rotation.x
		fa.get_child(0).rotation.y = neck.rotation.y
		fa.top_level = true;
		add_child(fa);

func _process(delta):
	neck.position = Vector3(position.x,position.y,position.z);
	var _pistol_rot = _pistol_origin_rot;
	if !gunAnim.is_playing():
		_pistol_rot = Vector3(
		clamp(_pistol_origin_rot.x + (cam_relative.y * GUN_SWAY_MULT), -30, 30),
		clamp(_pistol_origin_rot.y + (cam_relative.x * GUN_SWAY_MULT), -35, 30),
		_pistol_origin_rot.z
		);
	
	gun.rotation_degrees = gun.rotation_degrees.lerp(_pistol_rot,delta * GUN_SWAY_SPEED);
	cam_relative = Vector2.ZERO;
	
	if Input.is_action_just_pressed("gun1"):
		gunSelected = 0;
	if Input.is_action_just_pressed("gun2"):
		gunSelected = 1;
	if Input.is_action_just_pressed("reloadKnife"):
		facas.reload();
	
	if gunSelected == 0:
		gun.visible = true;
		facas.visible = false;
	elif gunSelected == 1:
		gun.visible = false;
		facas.visible = true;
	
	if Input.is_action_just_pressed("smoke"):
		spawnSmoke();
	#rot = Vector2(rad_to_deg(neck.rotation.y)+180,rad_to_deg(camera.rotation.x));
	#rat = Vector3(
	#	sin(neck.rotation.y+deg_to_rad(180))*1,
	#	sin(camera.rotation.x)*1,
	#	cos(neck.rotation.y+deg_to_rad(180)-sin(camera.rotation.x)*1)
	#)
	#label.text = str(rot)+"\n"+str(rat);
	
	#ball.position = Vector3(position.x+rat.x,position.y+1.2+rat.y,position.z+rat.z);

func _physics_process(delta):
	rayCast.rotation = Vector3(camera.rotation.x,neck.rotation.y,0);
	
	
	if !onDash:
		if Input.is_action_just_pressed("strafe") and strafeCount > 0:
			velocity.y = strafeForce;
			strafeCount-=1;
		
		
		if Input.is_action_just_pressed("fire"):
			if rayCast.get_collider() is RigidBody3D:
				pass
				#rayCast.get_collider().apply_impulse(-((position-rayCast.get_collider().position))*bulletForce)
		# Add the gravity.
		if not is_on_floor():
			if Input.is_action_pressed("space"):
				velocity.y -= gravity * delta;
				velocity.y = clamp(velocity.y,-1,10)
			else:
				velocity.y -= gravity * delta;
		else:
			strafeCount = strafeCountMax;
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("fire"):
			gunFire()
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, 1)
				velocity.z = move_toward(velocity.z, 0, 1)
			else:
				velocity.x = move_toward(velocity.x, 0, 0.1)
				velocity.z = move_toward(velocity.z, 0, 0.1)
		
		if Input.is_action_just_pressed("dash"):
			velocity = -Vector3(sin(neck.rotation.y+deg_to_rad(180)),0,cos(neck.rotation.y+deg_to_rad(180))).normalized()*dashForce;
			onDash = true;
			dashTimer.start(0.4)
	else:
		if dashTimer.time_left <= 0:
			onDash = false;
	move_and_slide()
