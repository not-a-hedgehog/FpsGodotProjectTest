extends Node3D

@onready var gun := $"../CanvasLayer/SubViewportContainer/SubViewport/Camera3D/gun"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_rotation = gun.global_rotation
