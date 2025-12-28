extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

var phase := Globals.Phase.PLACE

var player_turn := Globals.Land.TOP

var team_turn := Globals.Team.V

var did_pocket := false

var did_drown := false

var vert_team_color := Globals.PieceType.NONE

@onready var _board = $Board

@export var piece_count = 14

func get_team_color(team: Globals.Team):
	if vert_team_color == Globals.PieceType.NONE:
		return Globals.PieceType.NONE

	match team:
		Globals.Team.V:
			return vert_team_color
		Globals.Team.H:
			match vert_team_color:
				Globals.PieceType.GREEN:
					return Globals.PieceType.RED
				Globals.PieceType.RED:
					return Globals.PieceType.GREEN

func update_label():
	$Label.text = ("VERT " if team_turn == Globals.Team.V else "HORIZ ") + str(Globals.Land.keys()[player_turn]) + (" PLACE" if phase == Globals.Phase.PLACE else " SHOOT")
	$ColorLabel.text = "V: G | H: R" if vert_team_color == Globals.PieceType.GREEN else "V: R | H: G"
	if vert_team_color == Globals.PieceType.NONE:
		$ColorLabel.text = "Unassigned"

func start_placement():
	phase = Globals.Phase.PLACE
	did_pocket = false
	_board.init_placement(player_turn)
	update_label()

func next_turn():
	var next = (player_turn % 4) + 1
	player_turn = Globals.Land[Globals.Land.keys()[next]]
	team_turn = Globals.Team.H if team_turn == Globals.Team.V else Globals.Team.V
	did_drown = false
	start_placement()

func start_round():
	vert_team_color = Globals.PieceType.NONE
	
	var center := Vector2(window.size / 2)
	
	# Instantiate a white at the center
	var white = Piece.instantiate()
	white.init(center, Globals.PieceType.WHITE)
	add_child(white)
	
	for i in range((piece_count * 2) + 1):

		var piece = Piece.instantiate()
		var dir = Vector2.RIGHT.rotated(randf() * (2 * PI)) * 25
		
		var color = Globals.PieceType.BLACK if i == 0 else Globals.PieceType.RED if i % 2 == 0 else Globals.PieceType.GREEN
		
		piece.init(center + dir, color)
		add_child(piece)

	start_placement()

func _ready():
	_board.init_placement(player_turn)
	_board.position = (window.size / 2) - (Vector2i(1200, 1200) / 2)

	start_round()

func _on_piece_pocketed(type: Globals.PieceType) -> void:
	if type == Globals.PieceType.WHITE:
		# Place additional piece
		did_drown = true
		next_turn()

	if vert_team_color == Globals.PieceType.NONE:
		if team_turn == Globals.Team.V:
			vert_team_color = type
		elif type == Globals.PieceType.GREEN:
			vert_team_color = Globals.PieceType.RED
		else:
			vert_team_color = Globals.PieceType.GREEN

	if get_team_color(team_turn) == type:
		did_pocket = true

	update_label()

func _on_stopped():
	if did_pocket:
		start_placement()
	else:
		next_turn()

func _on_board_clicked(global_pos: Vector2) -> void:
	var shooter = Piece.instantiate()

	shooter.init(global_pos, Globals.PieceType.SHOOTER)
	shooter.connect("piece_pocketed", _on_piece_pocketed)
	shooter.connect("stopped", _on_stopped)

	add_child(shooter)

	phase = Globals.Phase.SHOOT

	update_label()
