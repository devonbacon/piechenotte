extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

var red_score = 0
var green_score = 0

func _ready():
	_write_score()
	
	var shooter = Piece.instantiate()
	shooter.init(window.size / 2, Globals.PieceType.WHITE)
	shooter.connect("piece_pocketed", _on_piece_pocketed)

	add_child(shooter)

	var line = 1
	var count_in_line = 0

	for i in 10:
		var other = Piece.instantiate()
		var color = (i % 2) + 1
		other.init((window.size / 2) + Vector2i(count_in_line * 50, 100 - 10 * line), color)
		other.connect("piece_pocketed", _on_piece_pocketed)

		if count_in_line == line:
			line += 1
			count_in_line = 0
		else:
			count_in_line += 1

		add_child(other)

	$Board.position = (window.size / 2) - Vector2i(512, 512)


func _on_piece_pocketed(type: Globals.PieceType) -> void:
	_inc_score(type)
			
func _write_score():
	$Label.text = "RED: " + str(red_score) + " | GREEN: " + str(green_score)

func _inc_score(type: Globals.PieceType):
	match type:
		Globals.PieceType.RED:
			green_score += 1
		Globals.PieceType.GREEN:
			red_score += 1
	
	_write_score()
