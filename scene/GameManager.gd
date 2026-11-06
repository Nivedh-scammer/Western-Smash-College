# GameManager.gd
extends Node

var player1_resource: Character_Resource_Fighting
var player2_resource: Character_Resource_Fighting

func start_game(p1_res: Character_Resource_Fighting, p2_res: Character_Resource_Fighting) -> void:
	player1_resource = p1_res
	player2_resource = p2_res
	
	# Change scene to your actual combat map
	get_tree().change_scene_to_file("res://scene/gym_level.tscn")
