extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var base_damage = 5
@export var speed = 150
@export var jump_impulse = 300

@onready var start_coords = $".".position
@onready var detection_area = $DetectionArea
@onready var action_timer = $ActionTimer
@onready var hazard = $HazardArea
@onready var color_rect = $ColorRect

var is_sleeping = true


@export var hp : float = 20


func _ready():
	hazard.damage = base_damage

func _process(delta):
	apply_gravity(delta)

	if is_sleeping:
		go_to(start_coords)
	if action_timer.timeout and is_on_floor():
		velocity.y -= jump_impulse
#		rotate(90)
	move_and_slide()
	is_need_to_kill()

	if hp <= 0:
		queue_free()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * 1 * delta


func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		is_sleeping = false
		go_to(body.position)



func go_to(target_position: Vector2):
	var direction = (target_position - position).normalized()
	velocity.x = direction.x * speed
	if abs(position.x - target_position.x) < 5 or is_on_floor():
		velocity.x = 0


func is_need_to_kill():
	if position.y > 1000 and not is_on_floor():
		queue_free()


func take_damage(damage):
	hp -= damage / 5
	color_rect.color.r = color_rect.color.r - damage * 0.01
	
