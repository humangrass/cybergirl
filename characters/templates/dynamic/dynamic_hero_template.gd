extends CharacterBody2D

@export var hero_data: DynamicHeroData
@export var is_player: bool

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var default_damage = 0

@onready var jumps_left : int

@onready var hero = $"."
@onready var starting_position = hero.position
@onready var camera = $Camera2D

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var damage_timer = $DamageTimer


@onready var animated_hit_flash = $HitFlashAnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var animation_tree : AnimationTree = $AnimationTree

@onready var hero_collision = $HeroCollision

@onready var laser_beam = $LaserBeam

@onready var platform_detector : RayCast2D = $PlatformDetector


var default_sprite_scale

func _ready():
	if not hero_data.is_laser_enabled:
		laser_beam.queue_free()
	animation_tree.active = true
	default_sprite_scale = sprite_2d.scale.y
	if not is_player:
		camera.enabled = is_player
		camera.hide()


func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if hero.position.y > 1000:
		restart()

	update_animations(direction)

	apply_gravity(delta)
	apply_friction(direction[0], delta)
	apply_air_resistance(direction[0], delta)
	handle_acceleration(direction[0], delta)
	handle_jump()
	handle_sitting()

	handle_laser_beam()

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


func update_animations(direction):
	animation_tree.set("parameters/Move/blend_position", direction[0])
	if direction[0] != 0:
		sprite_2d.flip_h = direction[0] < 0
		animation_player.play("run")
	elif not is_on_floor():
		animation_player.play("jump")
	elif direction[0] == 0:
		animation_player.play("idle")


func collect_money(denomination=1):
	hero_data.money += denomination
	#hero_data.laser_attack_multiplier += 0.5


#region Movements
func handle_jump():
	if is_on_floor():
		jumps_left = hero_data.max_jumps
	var is_coyote_jump = coyote_jump_timer.time_left > 0.0
	var is_wall_jump = is_on_wall() and hero_data.is_wall_jump_enabled

	if is_on_floor() or is_coyote_jump:
		if Input.is_action_just_pressed("ui_up") and is_player:
			velocity.y = hero_data.jump_velocity
			jumps_left -= 1

	if not is_on_floor() and not is_coyote_jump:
		if Input.is_action_just_pressed("ui_up") and jumps_left > 0 and is_player:
			velocity.y = hero_data.jump_velocity * hero_data.second_jump_scale
			jumps_left -= 1


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
	if platform_detector.is_colliding():
		var colliding_object = platform_detector.get_collider()
		if colliding_object and colliding_object.is_in_group("Platform"):
			if Input.is_action_pressed("ui_down") and is_player:
				hero.position.y += 1


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
	if damage_timer.timeout and damage_timer.autostart and is_player:
		# invulnerability while flashing
		if not animated_hit_flash.is_playing():
			animated_hit_flash.play("hit_flash")
			hero_data.hp -= damage
		if hero_data.hp <= 0:
			restart()
	else:
		# for npc
		animated_hit_flash.play("hit_flash")
		hero_data.hp -= damage

func restart():
	hero_data.hp = hero_data.max_hp
	global_position = starting_position

#endregion

#region Attack
func handle_laser_beam():
	if laser_beam.is_colliding():
		var colliding_object = laser_beam.get_collider()
		if colliding_object and colliding_object.is_in_group("Enemy"):
			colliding_object.take_damage(hero_data.laser_attack * hero_data.laser_attack_multiplier)
#endregion
