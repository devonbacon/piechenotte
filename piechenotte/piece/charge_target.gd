extends Node2D

signal fire

@export var MAX_DISTANCE_PX = 100

var source_pos: Vector2

var enabled = false

func _ready():
	hide()
	
func do_rotate():
	var direction = global_position - source_pos
	
	rotation = atan2(direction.y, direction.x)

func set_global_pos(source: Vector2, target: Vector2):
	var distance = (target - source).normalized() * clamp(target.distance_to(source), 0, MAX_DISTANCE_PX)

	global_position = source + distance

func init(pos: Vector2):
	source_pos = pos
	enabled = true
	do_rotate()
	show()
	

func _process(_delta) -> void:
	if enabled and Input.is_action_pressed("click"):
		set_global_pos(source_pos, get_global_mouse_position())
		
		do_rotate()


func _input(event):
	if enabled and event.is_action_released("click"):
		fire.emit(global_position)
		enabled = false
		hide()
