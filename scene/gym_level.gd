extends Node2D

@onready var p1_spawn_point: Marker2D = $P1SpawnPoint
@onready var p2_spawn_point: Marker2D = $P2SpawnPoint

func _ready() -> void:
	spawn_players()

func spawn_players() -> void:
	# Spawn Player 1
	if GameManager.player1_resource and GameManager.player1_resource.character_scene:
		var p1_instance = GameManager.player1_resource.character_scene.instantiate()
		p1_instance.global_position = p1_spawn_point.global_position
		add_child(p1_instance)

	# Spawn Player 2
	if GameManager.player2_resource and GameManager.player2_resource.character_scene:
		var p2_instance = GameManager.player2_resource.character_scene.instantiate()
		p2_instance.global_position = p2_spawn_point.global_position
		add_child(p2_instance)
