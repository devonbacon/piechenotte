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

signal bigmessagedone

func show_big_message(message: String, time: int):
	bigmessage.emit(message, time)
	await get_tree().create_timer(time).timeout
	bigmessagedone.emit()

var piece_count: int

var white_count: int

var black_count: int

var score_limit: int

var colorblind_mode: bool

var player_names := {
	Land.TOP: "",
	Land.BOTTOM: "",
	Land.RIGHT: "",
	Land.LEFT: ""
}

func reset():
	score_limit = 30
	white_count = 1
	black_count = 1
	piece_count = 14
	player_names[Land.BOTTOM] = "Player One"
	player_names[Land.TOP] = "Player Three"
	player_names[Land.RIGHT] = "Player Two"
	player_names[Land.LEFT] = "Player Four"
	colorblind_mode = false

func _ready():
	reset()
	
var player_to_team = {
	Land.TOP: Team.V,
	Land.BOTTOM: Team.V,
	Land.RIGHT: Team.H,
	Land.LEFT: Team.H
}

var piece_points := {
	PieceType.WHITE: 10,
	PieceType.BLACK: 5,
	PieceType.RED: 1,
	PieceType.GREEN: 1
}

var turn_order := [
	Land.BOTTOM,
	Land.RIGHT,
	Land.TOP,
	Land.LEFT,
]
