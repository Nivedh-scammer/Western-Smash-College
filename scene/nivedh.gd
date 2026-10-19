extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Health stats
var max_health: int = 100
var current_health: int = 100

# Stun tracking
var is_stunned: bool = false

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If stunned, freeze controls and stop horizontal movement
	if is_stunned:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# Handle jump using "Jump P2" (I)
	if Input.is_action_just_pressed("Jump P2") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

	# Get horizontal movement direction ("Left P2" / "Right P2")
	var direction := Input.get_axis("Left P2", "Right P2")
	
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animations(direction)
	move_and_slide()

func update_animations(direction: float) -> void:
	if is_on_floor():
		# Let jump finish playing upon landing before returning to idle/walk
		if sprite.animation == "jump" and sprite.is_playing():
			return
		
		if direction != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		if sprite.animation != "jump":
			sprite.play("jump")

# Applies 3-second stun state
func apply_stun(duration: float = 3.0) -> void:
	if is_stunned:
		return
		
	is_stunned = true
	sprite.modulate = Color(0.6, 0.6, 1.0, 1.0) # Tint blue to show stun
	
	await get_tree().create_timer(duration).timeout
	
	is_stunned = false
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0) # Reset color

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_animation_finished() -> void:
	pass
