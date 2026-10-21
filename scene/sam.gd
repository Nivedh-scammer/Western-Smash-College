extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Health and combat stats
var max_health: int = 150
var current_health: int = 150
var punch_damage: int = 30

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var punch_hitbox: CollisionShape2D = $Hitbox/Punch
@onready var stun_hitbox_1: CollisionShape2D = $Hitbox/Stun1
@onready var stun_hitbox_2: CollisionShape2D = $Hitbox/Stun2

# Action state flags
var is_punching: bool = false
var is_stunning: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle attacks when grounded/idle
	if not is_punching and not is_stunning:
		if Input.is_action_just_pressed("Punch P1"):
			is_punching = true
			velocity.x = 0
			sprite.play("punch")
		elif Input.is_action_just_pressed("Stun P1"):
			is_stunning = true
			velocity.x = 0
			sprite.play("stun")

	# Handle jump
	if Input.is_action_just_pressed("Jump P1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_punching and not is_stunning:
			sprite.play("jump")

	# Movement logic
	var direction := Input.get_axis("Left P1", "Right P1")
	
	if not is_punching and not is_stunning:
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
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
			sprite.play("Idle")
	else:
		if sprite.animation != "jump" and not is_punching and not is_stunning:
			sprite.play("jump")

func manage_hitboxes() -> void:

	if sprite.animation == "punch" and sprite.frame == 2:
		if punch_hitbox: punch_hitbox.disabled = false
	else:
		if punch_hitbox: punch_hitbox.disabled = true


	if sprite.animation == "stun" and sprite.frame >= 2:
		if stun_hitbox_1: stun_hitbox_1.disabled = false
		if stun_hitbox_2: stun_hitbox_2.disabled = false
	else:
		if stun_hitbox_1: stun_hitbox_1.disabled = true
		if stun_hitbox_2: stun_hitbox_2.disabled = true

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_animation_finished() -> void:
	if sprite.animation == "punch":
		is_punching = false
		manage_hitboxes()
	elif sprite.animation == "stun":
		is_stunning = false
		manage_hitboxes()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == self:
		return
		
	if is_punching and body.has_method("take_damage"):
		body.take_damage(punch_damage)
	elif is_stunning and body.has_method("apply_stun"):
		body.apply_stun(3.0)
