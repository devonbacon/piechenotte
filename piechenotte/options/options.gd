extends CanvasLayer

signal exit

var red = preload("res://assets/red.png")
var green = preload("res://assets/green.png")

func do_hide():
	%OptsContainer.hide()
	
func do_show():
	%OptsContainer.show()

func _on_button_pressed() -> void:
	exit.emit()
	
func update():
	%PieceCount.value = Globals.piece_count
	%Score.value = Globals.score_limit
	%WhiteCount.value = Globals.white_count
	%BlackCount.value = Globals.black_count
	%BottomName.text = Globals.player_names[Globals.Land.BOTTOM]
	%RightName.text = Globals.player_names[Globals.Land.RIGHT]
	%LeftName.text = Globals.player_names[Globals.Land.LEFT]
	%TopName.text = Globals.player_names[Globals.Land.TOP]
	%Colorblind.button_pressed = Globals.colorblind_mode
	%Colorblind.icon = green if Globals.colorblind_mode else red
	
func _ready():
	update()

func _process(_delta):
	%PCLabel.text = "Piece Count (" + str(Globals.piece_count) + ")"
	%ScoreLabel.text = "Score to Win (" + str(Globals.score_limit) + ")"
	%WCLabel.text = "White Count (" + str(Globals.white_count) + ")"
	%BCLabel.text = "Black Count (" + str(Globals.black_count) + ")"

func _on_piece_count_value_changed(value: float) -> void:
	Globals.piece_count = int(value)

func _on_score_value_changed(value: float) -> void:
	Globals.score_limit = int(value)

func _on_white_count_value_changed(value: float) -> void:
	Globals.white_count = int(value)

func _on_black_count_value_changed(value: float) -> void:
	Globals.black_count = int(value)

func _on_reset_pressed() -> void:
	Globals.reset()
	update()

func _on_bottom_name_text_changed() -> void:
	Globals.player_names[Globals.Land.BOTTOM] = %BottomName.text

func _on_right_name_text_changed() -> void:
	Globals.player_names[Globals.Land.RIGHT] = %RightName.text

func _on_top_name_text_changed() -> void:
	Globals.player_names[Globals.Land.TOP] = %TopName.text

func _on_left_name_text_changed() -> void:
	Globals.player_names[Globals.Land.LEFT] = %LeftName.text

func _on_colorblind_toggled(toggled_on: bool) -> void:
	Globals.colorblind_mode = toggled_on
	update()
