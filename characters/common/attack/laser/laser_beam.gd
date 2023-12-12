extends RayCast2D

@export var max_length = 4000
@export var is_casting := false

@onready var ray = $"."
@onready var line = $Line2D
@onready var end = $Marker2D

func _ready():
	line.hide()
	line.points = [10, 100]

func _physics_process(delta):
	print(delta)
	var cast_point = get_local_mouse_position().normalized() * max_length
	ray.target_position = cast_point

	if Input.is_action_pressed("mouse_left"):
		if line.visible != true:
			line.show()
	else:
		if line.visible == true:
			line.hide()

	if is_colliding():
		cast_point = to_local(get_collision_point())
	line.points[1] = cast_point
	
