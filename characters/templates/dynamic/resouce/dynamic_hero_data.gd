class_name DynamicHeroData
extends Resource


#region Movements
@export var speed_scale = 1.0
@export var acceleration_scale = 1.0
@export var friction_scale = 1.0

@export var speed = 100.0
@export var acceleration = 600.0
@export var friction = 800.0

@export var gravity_scale = 1.0
@export var air_resistance = 200.0
@export var air_acceleration = 400.0

@export var jump_velocity = -300.0
@export var max_jumps = 3
@export var second_jump_scale = 0.8
@export var is_wall_jump_enabled = false
#endregion


#region PlayerStats
@export var max_hp = 20.0
@export var hp = 20.0

@export var melee_attack = 4.0
@export var melee_attack_range = 100.0

@export var is_laser_enabled : bool = false
@export var range_attack = 1.5
@export var range_attack_radius = 1.0
@export var range_attack_lifetime = 5.0

@export var money = 10
@export var biomaterial = 10
@export var metall = 10
#endregion


