extends RigidBody2D

@export var target_scene: PackedScene

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		$ChargeTarget.init(position)




func _on_charge_target_fire(pos: Vector2) -> void:
	var distance = pos - position
	
	apply_impulse(distance)
