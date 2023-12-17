extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		queue_free()
		body.collect_money(1)
		var hearts = get_tree().get_nodes_in_group("Hearts")
		#if hearts.size() == 1:
		#	Events.level_completed.emit()
