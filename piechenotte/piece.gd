extends RigidBody2D

@export var target_scene: PackedScene

@export var IMPULSE_SCALE = 10

func init(pos: Vector2):
	global_position = pos

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		$ChargeTarget.init(position)

func _on_charge_target_fire(pos: Vector2) -> void:
	var distance = pos - position
	
	apply_impulse(distance * IMPULSE_SCALE)
