extends Sprite2D

var sourcePos: Vector2

func init(pos: Vector2):
	sourcePos = pos

func _input(event):
	
	print("input")
	
	if event is InputEventMouseMotion:
		global_position = event.position.clamp(sourcePos, sourcePos + Vector2(100, 100))

	if Input.is_action_just_released("click"):
		queue_free()
