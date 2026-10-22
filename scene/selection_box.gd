extends Control
class_name CharacterSelectionBox

@export var selectable = true
@export var character: Character_Resource_Fighting

@onready var p_1_texture: TextureRect = $P1Texture
@onready var p_2_texture: TextureRect = $P2Texture

enum Player {NONE, PLAYER1, PLAYER2}

var selected = false

func _ready() -> void:
	pass
	
func set_player_selection(player: Player):
	match player:
		Player.PLAYER1:
			p_1_texture.show()
		Player.PLAYER2:
			p_2_texture.show()
	
func get_character():
	return character
	
func reset():
	selected = false

	p_1_texture.hide()
	p_2_texture.hide()






















					
