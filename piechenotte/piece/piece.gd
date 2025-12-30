extends RigidBody2D

signal piece_pocketed(type: Globals.PieceType)
signal shot

var MAX_DISTANCE := 300
@export var MAX_ADDTL_IMPULSE: int
@export var BASE_IMPULSE: int

var target_scene = preload("res://piece/charge_target.tscn")

var red = preload("res://assets/red.png")
var green = preload("res://assets/green.png")
var shooter = preload("res://assets/shooter.png")
var black = preload("res://assets/black.png")
var white = preload("res://assets/white.png")

var piece_type: Globals.PieceType

var did_shoot := false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if piece_type == Globals.PieceType.SHOOTER and event.is_action_pressed("click"):
		$ChargeTarget.init(global_position)

func _on_charge_target_fire(pull_pos: Vector2) -> void:
	var local_impulse = -to_local(pull_pos)
	apply_central_impulse(local_impulse)

	did_shoot = true
	shot.emit()

func init(pos: Vector2, type: Globals.PieceType):
	piece_type = type
	global_position = pos
	
	add_to_group(Globals.get_type_str(type))
	add_to_group("piece")

	if type == Globals.PieceType.RED:
		$Sprite2D.texture = red
	elif type == Globals.PieceType.GREEN:
		$Sprite2D.texture = green
	elif type == Globals.PieceType.SHOOTER:
		$Sprite2D.texture = shooter
	elif type == Globals.PieceType.WHITE:
		$Sprite2D.texture = white
	else:
		$Sprite2D.texture = black
		
	$AudioStreamPlayer.pitch_scale = randf_range(1.5, 2)

# Collisions masked such that we can only collide with the pockets
func _on_area_2d_area_entered(_area: Area2D) -> void:
	piece_pocketed.emit(piece_type)
	queue_free()

func _on_body_entered(_body: Node) -> void:
	$AudioStreamPlayer.play()
	
func _physics_process(_delta: float) -> void:
	if did_shoot && linear_velocity.length() < .2:
		queue_free()
