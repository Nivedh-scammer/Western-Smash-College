extends Control

@onready var p_1_selection: TextureRect = %P1Selection
@onready var grid_container: GridContainer = %GridContainer
@onready var p_2_selection: TextureRect = %P2Selection

var player1SelectionIndex: int = 0
var player2SelectionIndex: int = 2

var player1Character: Character_Resource_Fighting
var player2Character: Character_Resource_Fighting

func _ready() -> void:
	_refresh_selection()

func _refresh_selection():
	for child in grid_container.get_children():
		child.reset()
		
	var startContainerP1 = grid_container.get_child(player1SelectionIndex)
	var startContainerP2 = grid_container.get_child(player2SelectionIndex)
	
	startContainerP1.set_player_selection(CharacterSelectionBox.Player.PLAYER1)
	p_1_selection.texture = startContainerP1.get_character().texture
	
	startContainerP2.set_player_selection(CharacterSelectionBox.Player.PLAYER2)
	p_2_selection.texture = startContainerP2.get_character().texture

func _input(event: InputEvent) -> void:
	if not event.is_pressed(): return

	var player1Direction = Input.get_vector("Character selection left  P1", "Character selection right  P1", "Character selection up  P1", "Character selection down  P1")
	var player2Direction = Input.get_vector("Character selection left  P2", "Character selection right  P2", "Character selection up  P2", "Character selection down  P2", 1).round()

	if not player1Character:
		player1SelectionIndex = _get_selection_index(player1SelectionIndex, player1Direction)

	if not player2Character:
		player2SelectionIndex = _get_selection_index(player2SelectionIndex, player2Direction)

	_refresh_selection()

	if Input.is_action_just_pressed("accept P1"):
		player1Character = grid_container.get_child(player1SelectionIndex).get_character()
	if Input.is_action_just_pressed("accept P2"):
		player2Character = grid_container.get_child(player2SelectionIndex).get_character()

	_check_selection_done()

func _get_selection_index(currentIndex: int, direction: Vector2i):
	var index: int = currentIndex

	if direction.x:
		index = currentIndex + direction.x

	if direction.y:
		index = currentIndex + direction.y * grid_container.columns

	var selectedContainer = grid_container.get_child(index)
	if selectedContainer and selectedContainer.selectable and not selectedContainer.selected:
		return index
	else:
		return currentIndex

func _check_selection_done():
	if player1Character and player2Character:
		pass  
