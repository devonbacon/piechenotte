extends CanvasLayer

var green = preload("res://assets/green.png")
var white = preload("res://assets/white.png")
var red = preload("res://assets/red.png")
var black = preload("res://assets/black.png")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")


func _on_options_pressed() -> void:
	%MainMenu.hide()
	$Options.do_show()


func _on_quit() -> void:
	get_tree().quit()

func _ready():
	%Start.icon = black
	%Options.icon = black
	%Exit.icon = black
	$Options.do_hide()

func _on_start_mouse_entered() -> void:
	%Start.icon = green

func _on_start_mouse_exited() -> void:
	%Start.icon = black


func _on_options_mouse_entered() -> void:
	%Options.icon = white


func _on_options_mouse_exited() -> void:
	%Options.icon = black


func _on_exit_mouse_entered() -> void:
	%Exit.icon = red


func _on_exit_mouse_exited() -> void:
	%Exit.icon = black


func _on_options_exit() -> void:
	$Options.do_hide()
	%MainMenu.show()
