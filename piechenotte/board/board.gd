extends Node2D

signal clicked(global_pos: Vector2)

var placing_land = null
var follower_intersecting = null

@onready var _target = $PlaceTarget

func get_land(placing_on: Globals.Land):
	match placing_on:
		Globals.Land.TOP:
			return $TopLand
		Globals.Land.RIGHT:
			return $RightLand
		Globals.Land.BOTTOM:
			return $BottomLand
		Globals.Land.LEFT:
			return $LeftLand
		Globals.Land.CENTER:
			return $CenterLand

func init_placement(land: Globals.Land):
	if placing_land:
		placing_land.stop_placement()
		
	$AudioStreamPlayer.play()
		
	placing_land = get_land(land)
	placing_land.init_placement()
	_target.global_position = placing_land.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and placing_land and follower_intersecting == placing_land:
		placing_land.stop_placement()
		placing_land = null
		clicked.emit(get_global_mouse_position())
		_target.hide()

func _physics_process(_delta: float):
	var mouse_pos = get_global_mouse_position()

	$MouseFollower.global_position = mouse_pos

	if placing_land and !_target.visible:
		_target.show()

	if follower_intersecting == placing_land:
		_target.global_position = mouse_pos

func _on_mouse_follower_area_entered(area: Area2D) -> void:
	follower_intersecting = area

func _on_mouse_follower_area_exited(area: Area2D) -> void:
	if follower_intersecting == area:
		follower_intersecting = null
