extends Area2D

@export var damage = 2


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.handle_damage(true, damage)


func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.handle_damage(false, 0)
