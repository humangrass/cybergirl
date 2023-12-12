extends RayCast2D

@export var max_length : float = 4000
@export var animation_duration : float = 0.5
@export var slowdown_factor : float = 4

@onready var ray : RayCast2D = $"."
@onready var line : Line2D = $Line2D
@onready var end : Marker2D = $Marker2D

var animation_timer : float
var current_length : float


func _ready():
	line.hide()
	line.points = [10, 100]

func _process(delta: float) -> void:
	handle_action()
	if line.visible:
		animation_timer += delta
		var progress : float = animation_timer / animation_duration
		if progress > 1:
			progress = 1

		var target : Vector2 = get_local_mouse_position().normalized() * current_length
		var cast_point : Vector2 = ray.target_position.lerp(target, delta * slowdown_factor)
		ray.target_position = cast_point

		if is_colliding():
			cast_point = to_local(get_collision_point())
			current_length = cast_point.length()
		else:
			current_length = lerp(0.0, max_length, progress)
		line.points[1] = cast_point


func handle_action():
	if Input.is_action_pressed("mouse_left"):
		if not line.visible:
			animation_timer = 0.0
			ray.target_position = get_local_mouse_position().normalized()
			line.show()
	else:
		if line.visible:
			line.hide()
