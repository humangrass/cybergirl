extends CanvasLayer


@onready var transition_player = get_node("TransitionPlayer")

func fade_from_black():
	transition_player.play("fade_from_black")
	await transition_player.animation_finished

func fade_to_black():
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
