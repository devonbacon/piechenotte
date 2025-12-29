extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

var phase := Globals.Phase.PLACE

var turn_idx := 0

var did_pocket := false

var did_drown := false

var vert_team_color := Globals.PieceType.NONE

var player_to_team = {
	Globals.Land.TOP: Globals.Team.V,
	Globals.Land.BOTTOM: Globals.Team.V,
	Globals.Land.RIGHT: Globals.Team.H,
	Globals.Land.LEFT: Globals.Team.H
}

var dug_type = {
	Globals.Team.V: null,
	Globals.Team.H: null
}

var scores := {
	Globals.Team.V: 0,
	Globals.Team.H: 0
}

var piece_points := {
	Globals.PieceType.WHITE: 10,
	Globals.PieceType.BLACK: 5,
	Globals.PieceType.RED: 1,
	Globals.PieceType.GREEN: 1
}

var turn_order := [
	Globals.Land.BOTTOM,
	Globals.Land.LEFT,
	Globals.Land.TOP,
	Globals.Land.RIGHT,
]

@onready var _board = $Board

@export var piece_count := 14

@export var white_count := 1

@export var black_count := 1

@export var score_limit := 30

func get_team_turn():
	return player_to_team[turn_order[turn_idx]]
	
func get_player_turn():
	return turn_order[turn_idx]

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
	var team_turn = get_team_turn()
	$Label.text = ("VERT " if team_turn == Globals.Team.V else "HORIZ ") + str(turn_order[turn_idx]) + (" PLACE" if phase == Globals.Phase.PLACE else " SHOOT")
	$ColorLabel.text = "V: G | H: R" if vert_team_color == Globals.PieceType.GREEN else "V: R | H: G"
	if vert_team_color == Globals.PieceType.NONE:
		$ColorLabel.text = "Unassigned"
	$ScoreLabel.text = "V: " + str(scores[Globals.Team.V]) + " | H: " + str(scores[Globals.Team.H])

func start_placement():
	check_round_end()
	
	phase = Globals.Phase.PLACE
	did_pocket = false
	_board.init_placement(turn_order[turn_idx])
	update_label()

func next_turn():
	turn_idx = (turn_idx + 1) % turn_order.size()
	did_drown = false
	start_placement()

func start_round():
	# Preepmtive cleanup
	for node in Globals.get_all():
		node.queue_free()
		
	turn_idx = 0
		
	vert_team_color = Globals.PieceType.NONE
	
	var center := Vector2(window.size / 2)
	
	for i in range(white_count + black_count + (piece_count * 2)):

		var piece = Piece.instantiate()
		
		var dir = Vector2.RIGHT.rotated(randf() * (2 * PI)) * 25
		
		var placement = center if i == 0 else center + dir
		
		var color = (
			Globals.PieceType.WHITE if i < white_count
				else Globals.PieceType.BLACK if i < (black_count + white_count)
				else Globals.PieceType.RED if i % 2 == 0 else Globals.PieceType.GREEN
		)
		
		piece.init(placement, color)
		
		piece.connect("piece_pocketed", _on_piece_pocketed)
		
		add_child(piece)

	start_placement()

func _ready():
	_board.init_placement(turn_order[turn_idx])
	_board.position = (window.size / 2) - (Vector2i(1200, 1200) / 2)
	start_round()
	
func add_score(team: Globals.Team, type: Globals.PieceType, mult := 1):
	scores[team] = scores[team] + (piece_points[type] * mult)
	check_game_end()
	update_label()
	
func check_game_end():
	if scores[Globals.Team.V] > score_limit:
		print("Game over! Vertical wins")
		get_tree().reload_current_scene()
	elif scores[Globals.Team.H] > score_limit:
		print("Game over! Horizontal wins")
		get_tree().reload_current_scene()
	
func check_round_end():
	# check if either team won
	var greens = Globals.get_pieces(Globals.PieceType.GREEN).size()
	var reds = Globals.get_pieces(Globals.PieceType.RED).size()

	var winning_team: Globals.Team = Globals.Team.NONE
	
	if greens == 0 and reds == 0:
		# Tie, nobody gets points!
		start_round()
		return
	elif greens == 0:
		winning_team = Globals.Team.V if vert_team_color == Globals.PieceType.GREEN else Globals.Team.H
		add_score(winning_team, Globals.PieceType.RED, reds)
	elif reds == 0:
		winning_team = Globals.Team.V if vert_team_color == Globals.PieceType.RED else Globals.Team.H
		add_score(winning_team, Globals.PieceType.GREEN, greens)
		
	if winning_team == Globals.Team.NONE:
		return;
		
	var whites = Globals.get_pieces(Globals.PieceType.WHITE).size()
	var blacks = Globals.get_pieces(Globals.PieceType.BLACK).size()
	
	if whites > 0:
		add_score(winning_team, Globals.PieceType.WHITE, whites)
	if blacks > 0:
		add_score(winning_team, Globals.PieceType.BLACK)
	
	start_round()

func _on_piece_pocketed(type: Globals.PieceType) -> void:
	var team_turn = get_team_turn()
	
	if type == Globals.PieceType.SHOOTER:
		# Place additional piece
		did_drown = true

	# If we sink a white or a black, need to mark that we dug a hole	
	elif type == Globals.PieceType.WHITE or type == Globals.PieceType.BLACK:
		# Mark as pocketed
		did_pocket = true
		
		# Edge case: Sinking a white/black while already dug
		if dug_type[team_turn]:
			add_score(team_turn, dug_type[team_turn])
		
		dug_type[team_turn] = type
	else:
		# Might need to assign a team color
		if vert_team_color == Globals.PieceType.NONE:
			if team_turn == Globals.Team.V:
				vert_team_color = type
			elif type == Globals.PieceType.GREEN:
				vert_team_color = Globals.PieceType.RED
			else:
				vert_team_color = Globals.PieceType.GREEN

		if get_team_color(team_turn) == type:
			# Pocketed the right color
			did_pocket = true
			
			# Bury the dug piece, if any
			if dug_type[team_turn]:
				add_score(team_turn, dug_type[team_turn])
				dug_type[team_turn] = Globals.PieceType.NONE
	
	update_label()
	
	if did_drown and vert_team_color != Globals.PieceType.NONE:
		_board.init_placement(Globals.Land.CENTER)
	elif !did_pocket and dug_type[team_turn]:
		_board.init_placement(Globals.Land.CENTER)
	elif !did_pocket:
		next_turn()

func _on_stopped():
	if did_pocket:
		start_placement()
	else:
		next_turn()

func _on_board_clicked(global_pos: Vector2) -> void:
	var team_turn = get_team_turn()
	# If the board emits this and we drowned, we're placing a new piece
	if did_drown:
		var count = get_tree().get_nodes_in_group(Globals.get_type_str(get_team_color(team_turn))).size()
		if count < piece_count:
			var piece = Piece.instantiate()
			piece.init(global_pos, get_team_color(team_turn))
			piece.connect("piece_pocketed", _on_piece_pocketed)
			add_child(piece)
			
		did_drown = false
		next_turn()
	# Else if we had a dug_type, we're placing that type back (did not sink)
	elif !did_pocket and dug_type[team_turn]:
		var piece = Piece.instantiate()
		piece.init(global_pos, dug_type[team_turn])
		piece.connect("piece_pocketed", _on_piece_pocketed)
		add_child(piece)
		dug_type[team_turn] = null
		next_turn()
	else:
		var shooter = Piece.instantiate()

		shooter.init(global_pos, Globals.PieceType.SHOOTER)
		shooter.connect("piece_pocketed", _on_piece_pocketed)
		shooter.connect("stopped", _on_stopped)

		add_child(shooter)

		phase = Globals.Phase.SHOOT

		update_label()
