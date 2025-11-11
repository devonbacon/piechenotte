extends RigidBody2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    print("hit")
    apply_impulse(Vector2(1,1));
