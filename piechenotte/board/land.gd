extends Area2D

var is_placing = false

func init_placement():
	is_placing = true
	start()
	queue_redraw()

func stop_placement():
	is_placing = false
	queue_redraw()
	
func _draw():
	if is_placing:
		var points: PackedVector2Array = $CollisionPolygon2D.polygon.duplicate()
		points.append(points[0])
		draw_polyline(points, Color.WHITE, 10)


var time := 0.5
var end := .25

func start():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", end, time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	if is_placing:
		tween.tween_callback(finish)

func finish():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	if is_placing:
		tween.tween_callback(start)
