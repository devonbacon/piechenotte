extends RigidBody2D

@export var target_scene: PackedScene

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    if event.is_action_pressed("click"):
        var target = target_scene.instantiate()
        add_child(target)
