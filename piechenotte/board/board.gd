extends Node2D

signal clicked(global_pos: Vector2)

var placing_on := Globals.Land.NONE
var follower_intersecting := false

func init_placement(land: Globals.Land):
    placing_on = land

func _unhandled_input(event: InputEvent) -> void:
    if (event.is_action_pressed("click") and follower_intersecting and placing_on != Globals.Land.NONE):
        placing_on = Globals.Land.NONE
        clicked.emit(get_global_mouse_position())
        $PlaceTarget.hide()

func get_land():
    match placing_on:
        Globals.Land.TOP:
            return $TopLand

func _physics_process(_delta: float):
    var mouse_pos = get_global_mouse_position()

    $MouseFollower.global_position = mouse_pos

    if placing_on != Globals.Land.NONE and !$PlaceTarget.visible:
        $PlaceTarget.show()

    if follower_intersecting:
        $PlaceTarget.global_position = mouse_pos

func _on_mouse_follower_area_entered(area: Area2D) -> void:
    if area == get_land():
        follower_intersecting = true


func _on_mouse_follower_area_exited(area: Area2D) -> void:
    if (area == get_land()):
        follower_intersecting = false
