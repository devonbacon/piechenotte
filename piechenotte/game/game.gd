extends Node

const Piece: PackedScene = preload("res://piece/piece.tscn")

@onready var window: Window = get_window()

var turn_idx := 0

var did_pocket := false

var did_drown := false

var did_shoot := false

var did_shoot_with_banked := false

var vert_team_color := Globals.PieceType.NONE

var banked_type = {
	Globals.Team.V: null,
	Globals.Team.H: null
}

var scores := {
	Globals.Team.V: 0,
	Globals.Team.H: 0
}

@onready var _board = $Board

func get_team_turn():
	return Globals.player_to_team[Globals.turn_order[turn_idx]]
	
func get_player_turn():
	return Globals.turn_order[turn_idx]

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

func _process(_delta):
	var player_name = Globals.player_names[Globals.turn_order[turn_idx]]
	%PlayerLabel.text = "Player: " + player_name
	
	var team_turn = get_team_turn()
	var team_color = get_team_color(team_turn)
	
	%ColorLabel.text = "Color: " + (
		"Unassigned" if team_color == Globals.PieceType.NONE
		else "Green" if team_color == Globals.PieceType.GREEN
		else "Red"
	)
	
	%HorizScore.text = "Horizontal: " + str(scores[Globals.Team.H])
	%VerticalScore.text = "Vertical: " + str(scores[Globals.Team.V])
	%Winlabel.text = "Score to win: " + str(Globals.score_limit)
	
	var dug = banked_type[team_turn]
	%BankedLabel.text = "Banked: " + str("White" if dug == Globals.PieceType.WHITE else "Black") if dug else ""
	
	%Debug.text = "dt: " + str(banked_type) + " dr: " + str(did_drown) + " | ct: " + str(Globals.get_pieces(get_team_turn()).size() >= Globals.piece_count)

func start_placement():
	check_round_end()
	var player_name = Globals.player_names[Globals.turn_order[turn_idx]]
	Globals.show_big_message(player_name, 2)
	
	_board.init_placement(Globals.turn_order[turn_idx])

func next_turn(): 
	turn_idx = (turn_idx + 1) % Globals.turn_order.size()
	did_drown = false
	did_pocket = false
	did_shoot_with_banked = false
	start_placement()

func start_round():
	# Preepmtive cleanup
	for node in Globals.get_all():
		node.queue_free()
		
	turn_idx = 0
		
	vert_team_color = Globals.PieceType.NONE
	
	var center := Vector2(600, 600)
	
	for i in range(Globals.white_count + Globals.black_count + (Globals.piece_count * 2)):

		var piece = Piece.instantiate()
		
		var dir = Vector2.RIGHT.rotated(randf() * (2 * PI)) * 25
		
		var placement = center if i == 0 else center + dir
		
		var color = (
			Globals.PieceType.WHITE if i < Globals.white_count
				else Globals.PieceType.BLACK if i < (Globals.black_count + Globals.white_count)
				else Globals.PieceType.RED if i % 2 == 0 else Globals.PieceType.GREEN
		)
		
		piece.init(placement, color)
		
		piece.connect("piece_pocketed", _on_piece_pocketed)
		
		add_child(piece)

	start_placement()
	
func handle_big_message(message: String, time: int):
	%BigMessage.text = message
	%BigMessage.show()
	await get_tree().create_timer(time).timeout
	%BigMessage.hide()

func _ready():
	Globals.bigmessage.connect(handle_big_message)
	start_round()
	
func add_score(team: Globals.Team, type: Globals.PieceType, mult := 1):
	scores[team] = scores[team] + (Globals.piece_points[type] * mult)
	$Points.play()
	check_game_end()
	
func check_game_end():
	if scores[Globals.Team.V] > Globals.score_limit:
		Globals.show_big_message("Vertical Team Wins!", 3)
		await Globals.bigmessage
		get_tree().reload_current_scene()
	elif scores[Globals.Team.H] > Globals.score_limit:
		Globals.show_big_message("Horizontal Team Wins!", 3)
		await Globals.bigmessage
		get_tree().reload_current_scene()
	
func check_round_end():
	# check if either team won
	var greens = Globals.get_pieces(Globals.PieceType.GREEN).size()
	var reds = Globals.get_pieces(Globals.PieceType.RED).size()

	var winning_team: Globals.Team = Globals.Team.NONE
	
	if greens == 0:
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
		
	Globals.show_big_message("Vertical" if winning_team == Globals.Team.V else "Horizontal" + " team wins round!", 3)
	
	start_round()

func _on_piece_pocketed(type: Globals.PieceType) -> void:
	var team_turn = get_team_turn()
	
	if type == Globals.PieceType.SHOOTER:
		# Place additional piece
		did_drown = true
		$Sunk.play()

	# If we sink a white or a black, need to mark that we dug a hole
	elif type == Globals.PieceType.WHITE or type == Globals.PieceType.BLACK:
		# Mark as pocketed
		did_pocket = true
		
		# Edge case: Sinking a white/black while already dug
		if banked_type[team_turn]:
			add_score(team_turn, banked_type[team_turn])
		else:
			$Pocketed.play()
			
		banked_type[team_turn] = type
		
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
			$Pocketed.play()
			
			# Bury the dug piece, if any
			if banked_type[team_turn]:
				add_score(team_turn, banked_type[team_turn])
				banked_type[team_turn] = null
				did_shoot_with_banked = false

#	If we didn't bury a banked piece, or we drowned after banking
func should_place_banked():
	var team_turn = get_team_turn()
	return (did_shoot_with_banked and banked_type[team_turn]) or (banked_type[team_turn] and did_drown)
		
func _physics_process(_delta: float) -> void:
	if !did_shoot:
		return
		
	for piece in Globals.get_all():
		if piece.linear_velocity.length() > .2:
			return
	
	did_shoot = false
	
	if should_place_banked():
		_board.init_placement(Globals.Land.CENTER)
	elif did_pocket and !did_drown:
		start_placement()
	elif did_drown:
		if Globals.get_pieces(get_team_turn()).size() >= Globals.piece_count:
			next_turn()
			return
			
		_board.init_placement(Globals.Land.CENTER)
	else:
		next_turn()
	
func _on_shot():
	did_shoot = true
	if banked_type[get_team_turn()]:
		did_shoot_with_banked = true

func _on_board_clicked(global_pos: Vector2) -> void:
	var team_turn = get_team_turn()
	
	if should_place_banked():
		var piece = Piece.instantiate()
		piece.init(global_pos, banked_type[team_turn])
		piece.connect("piece_pocketed", _on_piece_pocketed)
		add_child(piece)
		banked_type[team_turn] = null
		did_shoot_with_banked = false
		next_turn()
	# If the board emits this and we drowned, we're placing a penalty piece
	elif did_drown:
		var piece = Piece.instantiate()
		piece.init(global_pos, get_team_color(team_turn))
		piece.connect("piece_pocketed", _on_piece_pocketed)
		add_child(piece)

		next_turn()
	else:
		var shooter = Piece.instantiate()

		shooter.init(global_pos, Globals.PieceType.SHOOTER)
		shooter.connect("piece_pocketed", _on_piece_pocketed)
		shooter.connect("shot", _on_shot)

		add_child(shooter)

		did_pocket = false
		did_shoot_with_banked = false
		did_shoot = false


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")
