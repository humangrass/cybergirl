extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var base_damage = 5
@export var speed = 150
@export var jump_impulse = 300

@onready var start_coords = $".".position
@onready var action_timer = $ActionTimer
@onready var hazard = $HazardArea
@onready var color_rect = $ColorRect

var player

@onready var target = $Target

@export var hp : float = 20


func _ready():
	hazard.damage = base_damage
	player = get_parent().find_child("Player")

func _process(delta):
	apply_gravity(delta)
	aim()
	if target.target_position.length() < 200:
		go_to(player.position)
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


func aim():
	target.target_position = to_local(player.position)


func go_to(target_position: Vector2):
	var direction = (target_position - position).normalized()
	velocity.x = direction.x * speed
	if abs(position.x - target_position.x) < 5 or is_on_floor():
		velocity.x = 0


func is_need_to_kill():
	if position.y > 1000 and not is_on_floor():
		queue_free()


func take_damage(damage):
	hp -= damage
	color_rect.color.r = color_rect.color.r - damage * 0.03
	color_rect.color.b = color_rect.color.b - damage * 0.03
	color_rect.color.g = color_rect.color.g - damage * 0.03
	
