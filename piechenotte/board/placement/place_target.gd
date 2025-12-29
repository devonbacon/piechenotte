extends Node2D

var time := 0.5
var end := .25

func start():
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", end, time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.tween_callback(finish)

func finish():
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 1, time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(start)

func _ready():
	start()
