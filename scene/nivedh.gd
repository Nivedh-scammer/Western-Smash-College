extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Health stats for Nivedh
var max_health: int = 100
var current_health: int = 100

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	# Connect to the signal to know when animations finish
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump using "Jump P2" (I key)
	if Input.is_action_just_pressed("Jump P2") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")

	# Get input direction using "Left P2" (J) and "Right P2" (L)
	var direction := Input.get_axis("Left P2", "Right P2")
	
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Update movement animations
	update_animations(direction)

	move_and_slide()

func update_animations(direction: float) -> void:
	if is_on_floor():
		# Let the jump animation finish playing upon landing before switching to idle/walk
		if sprite.animation == "jump" and sprite.is_playing():
			return
		
		if direction != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		# Ensure jump animation plays while airborne
		if sprite.animation != "jump":
			sprite.play("jump")

# Function to handle taking damage
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_animation_finished() -> void:
	pass # Reserved for future action animations
