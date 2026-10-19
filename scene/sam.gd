extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Health and combat stats
var max_health: int = 150
var current_health: int = 150
var punch_damage: int = 25
var grab_damage: int = 65

@onready var sprite = $AnimatedSprite2D
@onready var punch_hitbox = $Hitbox/Punch

# Tracking state flags
var is_punching = false

func _ready() -> void:
	# Connect to the signal to know when animations finish
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump using your custom action "Jump P1"
	if Input.is_action_just_pressed("Jump P1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_punching:
			sprite.play("jump")

	# Handle punching input using your custom action "Punch P1"
	if Input.is_action_just_pressed("Punch P1") and not is_punching:
		is_punching = true
		velocity.x = 0 # Optional: Stops movement momentum when punching
		sprite.play("punch")

	# Get the input direction using your custom movement keys
	var direction := Input.get_axis("Left P1", "Right P1")
	
	# Only allow horizontal movement if not actively punching
	if not is_punching:
		if direction != 0:
			velocity.x = direction * SPEED
			
			# Flip the sprite and the hitbox area based on looking direction
			sprite.flip_h = direction < 0
			$Hitbox.scale.x = -1 if direction < 0 else 1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Update animations for ground movement
		update_animations(direction)
	else:
		# Slowly slide to a stop if punching mid-run
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Manage the hitbox toggle relative to the punch animation timeline
	if sprite.animation == "punch" and sprite.frame == 2:
		punch_hitbox.disabled = false
	else:
		punch_hitbox.disabled = true

func update_animations(direction: float) -> void:
	if is_on_floor():
		# Let the jump animation finish playing upon landing before switching to Idle/Walk
		if sprite.animation == "jump" and sprite.is_playing():
			return
		
		if direction != 0:
			sprite.play("walk")
		else:
			sprite.play("Idle")
	else:
		# Ensure jump animation plays while airborne if not punching
		if sprite.animation != "jump" and not is_punching:
			sprite.play("jump")

# Function to handle taking damage from opponents
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health) # Prevent health from dropping below 0
	
	if current_health <= 0:
		die()

func die() -> void:
	# Add death logic here (e.g., queue_free(), play death animation, restart level)
	queue_free()

# This function triggers automatically when any animation reaches its final frame
func _on_animation_finished() -> void:
	if sprite.animation == "punch":
		is_punching = false
