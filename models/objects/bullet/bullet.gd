extends Area2D


var direction : Vector2 = Vector2.RIGHT
var speed : float = 300

func _physics_process(delta):
	position += direction * speed * delta


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(1)
		queue_free()
