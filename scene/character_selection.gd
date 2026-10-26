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
	
	if startContainerP1:
		startContainerP1.set_player_selection(CharacterSelectionBox.Player.PLAYER1)
		var char1 = startContainerP1.get_character()
		if char1:
			p_1_selection.texture = char1.texture
	
	if startContainerP2:
		startContainerP2.set_player_selection(CharacterSelectionBox.Player.PLAYER2)
		var char2 = startContainerP2.get_character()
		if char2:
			p_2_selection.texture = char2.texture 
	
func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): 
		return

	var player1Direction = Input.get_vector("Character selection left P1", "Character selection right P1", "", "")
	var player2Direction = Input.get_vector("Character selection left P2", "Character selection right P2", "", "")

	if not player1Character and player1Direction != Vector2.ZERO:
		player1SelectionIndex = _get_selection_index(player1SelectionIndex, Vector2i(player1Direction))

	if not player2Character and player2Direction != Vector2.ZERO:
		player2SelectionIndex = _get_selection_index(player2SelectionIndex, Vector2i(player2Direction))

	_refresh_selection()
	
	# Player 1 Lock-In
	if Input.is_action_just_pressed("ui_accept") and not player1Character:
		var p1_box = grid_container.get_child(player1SelectionIndex)
		if p1_box and p1_box.selectable:
			player1Character = p1_box.get_character()
			
	# Player 2 Lock-In
	if Input.is_action_just_pressed("joypad_accept") and not player2Character:
		var p2_box = grid_container.get_child(player2SelectionIndex)
		if p2_box and p2_box.selectable:
			player2Character = p2_box.get_character()
	
	_check_selection_done()
	
func _get_selection_index(currentIndex: int, direction: Vector2i) -> int:
	var total_children = grid_container.get_child_count()
	if total_children == 0:
		return currentIndex

	var targetIndex: int = currentIndex
	
	if direction.x != 0:
		targetIndex += direction.x
		
	if direction.y != 0: 
		targetIndex += direction.y * grid_container.columns
		
	# Clamp index to keep it within valid grid bounds
	targetIndex = clamp(targetIndex, 0, total_children - 1)
	
	var selectedContainer = grid_container.get_child(targetIndex)
	
	# Only move if the box is valid and set to selectable
	if selectedContainer and "selectable" in selectedContainer and selectedContainer.selectable:
		return targetIndex
	else:
		return currentIndex
		
func _check_selection_done():
	if player1Character and player2Character:
		pass
