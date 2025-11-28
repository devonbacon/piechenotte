extends RigidBody2D

@export var target_scene: PackedScene

@export var IMPULSE_SCALE: int

var red = preload("res://piece/red.png")
var green = preload("res://piece/green.png")
var white = preload("res://piece/white.png")

enum PieceType { WHITE = 0, RED = 1, GREEN = 2 }

var piece_type: PieceType

func init(pos: Vector2, type: PieceType):
	piece_type = type
	global_position = pos
	
	if type == PieceType.RED:
		$Sprite2D.texture = red
	elif type == PieceType.GREEN:
		$Sprite2D.texture = green
	else:
		$Sprite2D.texture = white
	

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if piece_type == PieceType.WHITE and event.is_action_pressed("click"):
		$ChargeTarget.init(global_position)

func _on_charge_target_fire(pos: Vector2) -> void:
	var distance = pos - global_position

	apply_impulse(distance * IMPULSE_SCALE)
