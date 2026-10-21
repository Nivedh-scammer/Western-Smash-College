extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Health stats
var max_health: int = 100
var current_health: int = 100

# Action state flags
var is_stunned: bool = false
var is_shooting: bool = false

# Damage value for shooting
var shoot_damage: int = 20

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var shoot_hitbox: CollisionShape2D = $Hitbox/Shoot

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle stun state
	if is_stunned:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# Handle Shoot ("Shoot P2")
	if Input.is_action_just_pressed("Shoot P2") and not is_shooting:
		is_shooting = true
		velocity.x = 0
		sprite.play("shoot")

	# Handle jump ("Jump P2")
	if Input.is_action_just_pressed("Jump P2") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_shooting:
			sprite.play("jump")

	# Get horizontal movement direction ("Left P2" / "Right P2")
	var direction := Input.get_axis("Left P2", "Right P2")
	
	if not is_shooting:
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
			if hitbox:
				hitbox.scale.x = -1 if direction < 0 else 1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		update_animations(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	manage_hitboxes()

func update_animations(direction: float) -> void:
	if is_on_floor():
		if sprite.animation == "jump" and sprite.is_playing():
			return
		
		if direction != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		if sprite.animation != "jump" and not is_shooting:
			sprite.play("jump")

func manage_hitboxes() -> void:
	if sprite.animation == "shoot" and sprite.frame == 1:
		if shoot_hitbox:
			shoot_hitbox.disabled = false
	else:
		if shoot_hitbox:
			shoot_hitbox.disabled = true

func apply_stun(duration: float = 3.0) -> void:
	if is_stunned:
		return
		
	is_stunned = true
	sprite.modulate = Color(0.6, 0.6, 1.0, 1.0)
	
	await get_tree().create_timer(duration).timeout
	
	is_stunned = false
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_animation_finished() -> void:
	if sprite.animation == "shoot":
		is_shooting = false
		manage_hitboxes()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == self:
		return
		
	if is_shooting and body.has_method("take_damage"):
		body.take_damage(shoot_damage)
