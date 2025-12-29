extends Node

enum PieceType { NONE, SHOOTER, RED, GREEN, BLACK, WHITE }

func get_type_str(type: PieceType):
	return str(PieceType.keys()[type])
	
func get_pieces(type: PieceType):
	return get_tree().get_nodes_in_group(get_type_str(type))
	
func get_all():
	return get_tree().get_nodes_in_group("piece")

enum Phase { PLACE, SHOOT }

enum Land { NONE, TOP, RIGHT, BOTTOM, LEFT, CENTER }

enum Team { V, H, NONE }

signal bigmessage(message: String, time: int)

func show_big_message(message: String, time: int):
	bigmessage.emit(message, time)

var piece_count: int

var white_count: int

var black_count: int

var score_limit: int

var player_names := {
	Globals.Land.TOP: "",
	Globals.Land.BOTTOM: "",
	Globals.Land.RIGHT: "",
	Globals.Land.LEFT: ""
}

func reset():
	Globals.score_limit = 30
	Globals.white_count = 1
	Globals.black_count = 1
	Globals.piece_count = 2
	Globals.player_names[Globals.Land.BOTTOM] = "Player One"
	Globals.player_names[Globals.Land.TOP] = "Player Three"
	Globals.player_names[Globals.Land.RIGHT] = "Player Two"
	Globals.player_names[Globals.Land.LEFT] = "Player Four"

func _ready():
	reset()
	
var player_to_team = {
	Globals.Land.TOP: Globals.Team.V,
	Globals.Land.BOTTOM: Globals.Team.V,
	Globals.Land.RIGHT: Globals.Team.H,
	Globals.Land.LEFT: Globals.Team.H
}

var piece_points := {
	Globals.PieceType.WHITE: 10,
	Globals.PieceType.BLACK: 5,
	Globals.PieceType.RED: 1,
	Globals.PieceType.GREEN: 1
}

var turn_order := [
	Globals.Land.BOTTOM,
	Globals.Land.RIGHT,
	Globals.Land.TOP,
	Globals.Land.LEFT,
]
