extends RigidBody2D

signal piece_pocketed(type: Globals.PieceType)
signal stopped

@export var IMPULSE_SCALE: int

var target_scene = preload("res://piece/charge_target.tscn")

var red = preload("res://assets/red.png")
var green = preload("res://assets/green.png")
var white = preload("res://assets/white.png")

var piece_type: Globals.PieceType

var moving := false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if piece_type == Globals.PieceType.WHITE and event.is_action_pressed("click"):
        $ChargeTarget.init(global_position)

func _on_charge_target_fire(pos: Vector2) -> void:
    var distance = pos - global_position

    apply_impulse(distance * IMPULSE_SCALE)

    await get_tree().create_timer(.01).timeout

    moving = true

func init(pos: Vector2, type: Globals.PieceType):
    piece_type = type
    global_position = pos

    if type == Globals.PieceType.RED:
        $Sprite2D.texture = red
    elif type == Globals.PieceType.GREEN:
        $Sprite2D.texture = green
    else:
        $Sprite2D.texture = white

func on_pocketed() -> void:
    queue_free()

# Collisions masked such that we can only collide with the pockets
func _on_area_2d_area_entered(_area: Area2D) -> void:
    piece_pocketed.emit(piece_type)
    queue_free()

func _physics_process(_delta: float) -> void:
    if moving && linear_velocity.abs() < Vector2(0.1, 0.1):
        stopped.emit()
        queue_free()
