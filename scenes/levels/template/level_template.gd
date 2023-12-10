extends Node2D

@export var next_level: String
@export var prev_level: String


@onready var pause_menu = $CanvasLayer/PauseMenu


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)


func _input(event: InputEvent):
	if next_level and event.is_action_pressed("next_scene"):
		queue_free()
		SceneSwitcher.switch_scene(next_level)
	elif prev_level and event.is_action_pressed("prev_scene"):
		queue_free()
		SceneSwitcher.switch_scene(prev_level)

