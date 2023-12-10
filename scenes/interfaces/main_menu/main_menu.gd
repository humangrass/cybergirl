extends ColorRect

@export var continue_level: String
@export var first_level: String

@onready var btn_continue = $CenterContainer/VBoxContainer/Continue
@onready var btn_new_game = $CenterContainer/VBoxContainer/NewGame
@onready var btn_settings = $CenterContainer/VBoxContainer/Settings


func _ready():
	if not continue_level:
		btn_continue.hide()


func _on_continue_pressed():
	if continue_level:
		queue_free()
		SceneSwitcher.switch_scene(continue_level)


func _on_new_game_pressed():
	if first_level:
		queue_free()
		SceneSwitcher.switch_scene(first_level)
	else:
		btn_new_game.text = "Something Went Wrong. Reinstall the game!"


func _on_settings_pressed():
	btn_settings.text = "ha-ha"


func _on_exit_pressed():
	get_tree().quit()
