extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

func _ready():
	var shooter = Piece.instantiate()
	shooter.init(window.size / 2, "white")

	add_child(shooter)

	var line = 1
	var count_in_line = 0

	for i in 10:
		var other = Piece.instantiate()
		var color = "green" if i % 2 == 0 else "red"
		other.init((window.size / 2) + Vector2i(count_in_line * 50, 100 - 10 * line), color)

		if count_in_line == line:
			line += 1
			count_in_line = 0
		else:
			count_in_line += 1

		add_child(other)

	$Board.position = (window.size / 2) - Vector2i(512, 512)
