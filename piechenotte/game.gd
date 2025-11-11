extends Node

const Piece: PackedScene = preload("res://piece.tscn")

@onready var window: Window = get_window()

func _ready():
	var shooter = Piece.instantiate()
	shooter.init(window.size / 2)
	
	var other = Piece.instantiate()
	other.init((window.size / 2) + Vector2i(0, 100))
	
	add_child(shooter)
	add_child(other)
