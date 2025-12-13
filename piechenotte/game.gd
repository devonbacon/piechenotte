extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

var phase := Globals.Phase.PLACE

func _ready():
    update_label()

    $Board.init_placement(Globals.Land.TOP)

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
    pass

func _on_stopped():
    phase = Globals.Phase.PLACE
    $Board.init_placement(Globals.Land.TOP)
    update_label()

func update_label():
    $Label.text = "PLACE" if phase == Globals.Phase.PLACE else "SHOOT"

func _on_board_clicked(global_pos: Vector2) -> void:
    var shooter = Piece.instantiate()

    shooter.init(global_pos, Globals.PieceType.WHITE)
    shooter.connect("piece_pocketed", _on_piece_pocketed)
    shooter.connect("stopped", _on_stopped)

    add_child(shooter)

    phase = Globals.Phase.SHOOT

    update_label()
