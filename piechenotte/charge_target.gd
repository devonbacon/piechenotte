extends Marker2D

func _input(event):
    if event is InputEventMouseMotion:
        position = event.position

    if Input.is_action_just_released("click"):
        queue_free()
