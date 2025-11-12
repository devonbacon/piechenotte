extends Node

const Piece: PackedScene = preload("res://piece.tscn")

@onready var window: Window = get_window()

func _ready():
    var shooter = Piece.instantiate()
    shooter.init(window.size / 2)

    add_child(shooter)

    var line = 1
    var count_in_line = 0

    for i in 10:
        var other = Piece.instantiate()
        other.init((window.size / 2) + Vector2i(line * 10, 100 - 10 * i))

        if count_in_line == line:
            line += 1
            count_in_line = 0
        else:
            count_in_line += 1

        add_child(other)

    $Board.position = (window.size / 2) - Vector2i(350, 350)
