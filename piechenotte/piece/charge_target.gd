extends Node2D

signal fire

@export var MAX_DISTANCE_PX = 100

var source_pos: Vector2

var enabled = false

func _ready():
	hide()

func init(pos: Vector2):
	source_pos = pos
	enabled = true
	show()

func set_pos(source: Vector2, target: Vector2):
	var distance = (target - source).normalized() * clamp(target.distance_to(source), 0, MAX_DISTANCE_PX)

	global_position = source + distance
	
func scale():
	var distance = global_position.distance_to(source_pos)
	var magnitude = lerp(.01, .02, distance / MAX_DISTANCE_PX)

	$Sprite2D.scale = Vector2(magnitude, magnitude)

func _process(_delta) -> void:
	if enabled:
		set_pos(source_pos, get_global_mouse_position())
		look_at(source_pos)
		scale()


func _input(event):
	if enabled and event.is_action_released("click"):
		fire.emit(global_position)
		enabled = false
		hide()
		$AudioStreamPlayer.play()
		await get_tree().create_timer(.25).timeout
		$AudioStreamPlayer.stop()
