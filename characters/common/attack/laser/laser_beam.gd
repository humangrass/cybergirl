extends RayCast2D

@export var max_line_width : float = 20
@export var min_line_width : float = 3
@export var max_length : float = 4000
@export var animation_duration : float = 0.5
@export var slowdown_factor : float = 4

@onready var ray : RayCast2D = $"."
@onready var line : Line2D = $Line2D
@onready var end : Marker2D = $Marker2D

@onready var collision_particles = $CollisionParticles
@onready var is_emmiting : bool = false
var animation_timer : float
var current_length : float

func _ready():
	line.hide()
	line.points = [10, 100]
	line.width = min_line_width
	collision_particles.emitting = false


func _process(delta: float) -> void:
	handle_action(delta)
	is_emmiting = is_colliding() and line.visible
	if ray.enabled:
		is_emmiting = is_colliding() and line.visible

		if line.visible:
			animation_timer += delta
			var progress : float = animation_timer / animation_duration
			if progress > 1:
				progress = 1

			var mouse_normal = get_local_mouse_position().normalized()
			var target : Vector2 = mouse_normal * current_length

			var cast_point = ray.target_position.lerp(target, delta * slowdown_factor)
			ray.target_position = cast_point

			if is_colliding():
				if not collision_particles.visible:
					collision_particles.show()
				cast_point = to_local(get_collision_point())
				current_length = cast_point.length()
			else:
				if collision_particles.visible:
					collision_particles.hide()
				current_length = lerp(0.0, max_length, progress)
			line.points[1] = cast_point
			
			var collision_normal = ray.get_collision_normal()
			collision_particles.process_material.direction = Vector3(collision_normal.x, collision_normal.y, 0).normalized()
			collision_particles.position = cast_point
	collision_particles.emitting = is_emmiting


func handle_action(delta):
	if Input.is_action_pressed("mouse_left"):
		if not line.visible:
			ray.enabled=true
			animation_timer = 0.0
			ray.target_position = get_local_mouse_position().normalized()
			line.show()
		if line.width < max_line_width:
			line.width += delta * 10
	else:
		if line.width >= min_line_width:
			line.width -= 1
		else:
			if line.visible:
				ray.enabled=false
				line.hide()
