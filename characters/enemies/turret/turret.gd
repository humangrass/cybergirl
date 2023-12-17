extends CharacterBody2D

@onready var turret = $"."
@onready var target = $Target
@onready var timer = $Target/Timer

@export var ammo : PackedScene

@export var hp = 30

@onready var player

func _ready():
	player = get_parent().find_child("Player")

func _physics_process(delta):
	if hp <= 0:
		queue_free()
	_aim()
	_check_player_collision()
	

func _aim():
	target.target_position = to_local(player.position)

func _check_player_collision():
	if target.get_collider() == player and timer.is_stopped():
		timer.start()
	elif target.get_collider() != player and not timer.is_stopped():
		timer.stop()


func _on_timer_timeout():
	_shoot()

func _shoot():
	var bullet = ammo.instantiate()
	bullet.position = position
	bullet.direction = target.target_position.normalized()
	get_tree().current_scene.add_child(bullet)


func take_damage(damage):
	hp -= damage
	timer.wait_time += 0.01
