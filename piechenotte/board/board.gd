extends Node2D

signal clicked(global_pos: Vector2)

var placing_on := Globals.Land.NONE
var follower_intersecting := false

@onready var _target = $PlaceTarget

func init_placement(land: Globals.Land):
	placing_on = land
	follower_intersecting = false
	_target.global_position = get_land().global_position

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("click") and follower_intersecting and placing_on != Globals.Land.NONE):
		placing_on = Globals.Land.NONE
		clicked.emit(get_global_mouse_position())
		_target.hide()

func get_land():
	match placing_on:
		Globals.Land.TOP:
			return $TopLand
		Globals.Land.RIGHT:
			return $RightLand
		Globals.Land.BOTTOM:
			return $BottomLand
		Globals.Land.LEFT:
			return $LeftLand

func _physics_process(_delta: float):
	var mouse_pos = get_global_mouse_position()

	$MouseFollower.global_position = mouse_pos

	if placing_on != Globals.Land.NONE and !_target.visible:
		_target.show()

	if follower_intersecting:
		_target.global_position = mouse_pos

func _on_mouse_follower_area_entered(area: Area2D) -> void:
	if area == get_land():
		follower_intersecting = true


func _on_mouse_follower_area_exited(area: Area2D) -> void:
	if area == get_land():
		follower_intersecting = false
