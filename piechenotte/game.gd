extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

var phase := Globals.Phase.PLACE

var player_turn := Globals.Land.TOP

var did_pocket := false

func update_label():
    $Label.text = str(Globals.Land.keys()[player_turn]) + (" PLACE" if phase == Globals.Phase.PLACE else " SHOOT")

func start_placement():
    phase = Globals.Phase.PLACE
    did_pocket = false
    $Board.init_placement(player_turn)
    update_label()

func next_turn():
    var next = (player_turn % 4) + 1
    player_turn = Globals.Land[Globals.Land.keys()[next]]
    start_placement()

func start_round():
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

    start_placement()

func _ready():
    $Board.init_placement(player_turn)
    $Board.position = (window.size / 2) - Vector2i(512, 512)

    start_round()

func _on_piece_pocketed(type: Globals.PieceType) -> void:
    if type == Globals.PieceType.WHITE:
        next_turn()
    else:
        did_pocket = true

func _on_stopped():
    if did_pocket:
        start_placement()
    else:
        next_turn()

func _on_board_clicked(global_pos: Vector2) -> void:
    var shooter = Piece.instantiate()

    shooter.init(global_pos, Globals.PieceType.WHITE)
    shooter.connect("piece_pocketed", _on_piece_pocketed)
    shooter.connect("stopped", _on_stopped)

    add_child(shooter)

    phase = Globals.Phase.SHOOT

    update_label()
