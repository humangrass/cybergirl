extends CharacterBody2D

@export var hero_data: DynamicHeroData
@export var is_player: bool

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_sitting = false
var default_damage = 0

var air_jump = false
var jumps_left = 1

@onready var hero = $"."
@onready var starting_position = hero.position
@onready var camera = $Camera2D

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var damage_timer = $DamageTimer

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animated_hit_flash = $HitFlashAnimationPlayer

@onready var standing_collision = $StandingCollision
@onready var sitting_collision = $SittingCollision


func _ready():
	if not is_player:
		camera.enabled = is_player
		camera.hide()


func _physics_process(delta):
	handle_sitting()

	if hero.position.y > 1000:
		restart()
	apply_gravity(delta)
	handle_jump()

	var input_axis = Input.get_axis("ui_left", "ui_right")
	update_animations(input_axis)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)

	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	
	if default_damage != 0:
		take_damage(default_damage)


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * hero_data.gravity_scale * delta


func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func collect_money(denomination=1):
	hero_data.money += denomination


#region Movements
func handle_jump():
	if is_on_floor():
		air_jump = true
		jumps_left = hero_data.max_jumps
	var is_coyote_jump = coyote_jump_timer.time_left > 0.0
	var is_wall_jump = is_on_wall() and hero_data.is_wall_jump_enabled

	if is_on_floor() or is_coyote_jump and not is_wall_jump:
		if Input.is_action_just_pressed("ui_up") and is_player:
			velocity.y = hero_data.jump_velocity
			jumps_left -= 1

	if not is_on_floor() and not is_coyote_jump and not is_wall_jump:
		if Input.is_action_just_pressed("ui_up") and jumps_left > 0 and is_player:
			velocity.y = hero_data.jump_velocity * hero_data.second_jump_scale
			jumps_left -= 1
			air_jump = false

	# TODO: с этой фичей можно вылететь за пределы карты
	if is_wall_jump and not is_on_floor():
		var wall_normal = get_wall_normal()

		# for sloped surfaces
		var left_angle = abs(wall_normal.angle_to(Vector2.LEFT))
		var right_angle = abs(wall_normal.angle_to(Vector2.RIGHT))
		var is_need_jump_left = wall_normal.is_equal_approx(Vector2.LEFT) or left_angle < 10.0
		var is_need_jump_right =  wall_normal.is_equal_approx(Vector2.RIGHT) or right_angle < 10.0

		if (Input.is_action_just_pressed("ui_left") and is_player and is_need_jump_left) or (
				Input.is_action_just_pressed("ui_right") and is_player and is_need_jump_right):
			velocity.x = wall_normal.x * hero_data.speed
			velocity.y = hero_data.jump_velocity


func handle_sitting():
	if Input.is_action_pressed("ui_down") and is_player:
		is_sitting = true
	else: is_sitting = false

	if is_sitting:
		sitting_collision.disabled = false
		standing_collision.disabled = true
		animated_sprite_2d.scale = Vector2(1, 0.5)
	else:
		sitting_collision.disabled = true
		standing_collision.disabled = false
		animated_sprite_2d.scale = Vector2(1, 1)


func handle_acceleration(input_axis, delta):
	if is_on_floor():
		if input_axis != 0:
			velocity.x = move_toward(
				velocity.x,
				hero_data.speed * input_axis,
				hero_data.acceleration * delta
			)
	else:
		if input_axis != 0:
			velocity.x = move_toward(
				velocity.x,
				hero_data.speed * input_axis,
				hero_data.air_acceleration * delta
			)


func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, hero_data.friction * delta)


func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, hero_data.air_resistance * delta)

#endregion


#region Damage
func handle_damage(is_need_to_start_timer: bool, damage: int):
	damage_timer.autostart = is_need_to_start_timer
	default_damage = damage


func take_damage(damage):
	if damage_timer.timeout and damage_timer.autostart:
		# invulnerability while flashing
		if not animated_hit_flash.is_playing():
			animated_hit_flash.play("hit_flash")
			hero_data.hp -= damage
		if hero_data.hp <= 0:
			restart()


func restart():
	hero_data.hp = hero_data.max_hp
	global_position = starting_position

#endregion

