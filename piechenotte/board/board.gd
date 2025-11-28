extends Node2D

signal piece_pocketed

func handle_pocket(body: Node2D):
	piece_pocketed.emit(body)
	body.queue_free()
	
func _ready():
	$TopLeftPocket.connect("body_shape_entered", handle_pocket)
	$TopRightPocket.connect("body_shape_entered", handle_pocket)
	$BottomLeftPocket.connect("body_shape_entered", handle_pocket)
	$BottomRightPocket.connect("body_shape_entered", handle_pocket)
