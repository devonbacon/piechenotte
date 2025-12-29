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
