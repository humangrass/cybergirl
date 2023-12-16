extends ColorRect

@export var menu_scene: String

@onready var pause_menu = $"."
@onready var is_pause = false

func _ready():
	if not is_pause:
		pause_menu.hide()


func _input(event: InputEvent):
	if event.is_action_pressed("pause") and not is_pause:
		Engine.time_scale = 0
		pause_menu.show()
		is_pause = true
	elif event.is_action_pressed("pause") and is_pause:
		Engine.time_scale = 1
		pause_menu.hide()
		is_pause = false


func _on_continue_pressed():
	Engine.time_scale = 1
	pause_menu.hide()
	is_pause = false


func _on_save_game_pressed():
	pass # Replace with function body.


func _on_load_game_pressed():
	pass # Replace with function body.


func _on_settings_pressed():
	pass # Replace with function body.


func _on_menu_pressed():
	if menu_scene:
		SceneSwitcher.switch_scene(menu_scene)
		Engine.time_scale = 1
