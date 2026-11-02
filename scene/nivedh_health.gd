extends ProgressBar

@export var player: CharacterBody2D

func _ready() -> void:
	if player:
		max_value = player.max_health
		value = player.current_health
		
		player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int) -> void:
	value = new_health
