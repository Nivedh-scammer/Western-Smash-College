extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Health and combat stats
var max_health: int = 150
var current_health: int = 150
var punch_damage: int = 30

@onready var sprite = $AnimatedSprite2D
@onready var punch_hitbox = $Hitbox/Punch
@onready var stun_hitbox_1 = $Hitbox/Stun1
@onready var stun_hitbox_2 = $Hitbox/Stun2

# Action state flags
var is_punching = false
var is_stunning = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	
	# Connects the Hitbox Area2D signal automatically
	if has_node("Hitbox"):
		$Hitbox.body_entered.connect(_on_punch_body_entered)
		$Hitbox.body_entered.connect(_on_stun_body_entered)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump using "Jump P1" (W)
	if Input.is_action_just_pressed("Jump P1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_punching and not is_stunning:
			sprite.play("jump")

	# Handle Punch using "Punch P1" (E)
	if Input.is_action_just_pressed("Punch P1") and not is_punching and not is_stunning:
		is_punching = true
		velocity.x = 0
		sprite.play("punch")

	# Handle Stun using "Stun P1" (Q)
	if Input.is_action_just_pressed("Stun P1") and not is_punching and not is_stunning:
		is_stunning = true
		velocity.x = 0
		sprite.play("stun")

	# Get horizontal movement direction ("Left P1" / "Right P1")
	var direction := Input.get_axis("Left P1", "Right P1")
	
	if not is_punching and not is_stunning:
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
			$Hitbox.scale.x = -1 if direction < 0 else 1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		update_animations(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Toggle hitboxes based on animation frame
	manage_hitboxes()

func update_animations(direction: float) -> void:
	if is_on_floor():
		if sprite.animation == "jump" and sprite.is_playing():
			return
		
		if direction != 0:
			sprite.play("walk")
		else:
			sprite.play("Idle")
	else:
		if sprite.animation != "jump" and not is_punching and not is_stunning:
			sprite.play("jump")

func manage_hitboxes() -> void:
	# Enable Punch Hitbox on frame 2
	if sprite.animation == "punch" and sprite.frame == 2:
		if punch_hitbox: punch_hitbox.disabled = false
	else:
		if punch_hitbox: punch_hitbox.disabled = true

	# Enable Stun Hitboxes on frame 2 and onwards
	if sprite.animation == "stun" and sprite.frame >= 2:
		if stun_hitbox_1: stun_hitbox_1.disabled = false
		if stun_hitbox_2: stun_hitbox_2.disabled = false
	else:
		if stun_hitbox_1: stun_hitbox_1.disabled = true
		if stun_hitbox_2: stun_hitbox_2.disabled = true

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_animation_finished() -> void:
	if sprite.animation == "punch":
		is_punching = false
	elif sprite.animation == "stun":
		is_stunning = false

# Signal callbacks that trigger when Hitbox touches another player
func _on_punch_body_entered(body: Node2D) -> void:
	if body != self and is_punching and body.has_method("take_damage"):
		body.take_damage(punch_damage)

func _on_stun_body_entered(body: Node2D) -> void:
	if body != self and is_stunning and body.has_method("apply_stun"):
		body.apply_stun(3.0)
