extends CharacterBody2D

# ===============================
# ESTADOS DEL JUGADOR
# ===============================
enum PlayerState {
	IDLE,
	WALK,
	CAST,
	FISHING,
	REEL
}

# ===============================
# VARIABLES
# ===============================
@export var speed := 3000.0

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine = anim_tree["parameters/playback"]

var state: PlayerState = PlayerState.IDLE
var can_fish := false
var move_dir := 0

# ===============================
# READY
# ===============================
func _ready() -> void:
	anim_tree.active = true
	_set_state(PlayerState.IDLE)

# ===============================
# PHYSICS PROCESS
# ===============================
func _physics_process(delta: float) -> void:
	_handle_input()
	_handle_movement(delta)
	_update_animation()

# ===============================
# INPUT (REGLAS CLARAS)
# ===============================
func _handle_input() -> void:
	# Lanzar sedal (solo dentro del área y en idle)
	if Input.is_action_just_pressed("cast") \
	and can_fish \
	and state == PlayerState.IDLE:
		_set_state(PlayerState.CAST)
		return

	# Recoger sedal (solo si está pescando y dentro del área)
	if Input.is_action_just_pressed("reel") \
	and can_fish \
	and state == PlayerState.FISHING:
		_set_state(PlayerState.REEL)
		return

# ===============================
# MOVIMIENTO
# ===============================
func _handle_movement(delta: float) -> void:
	# Estados que bloquean movimiento
	if state in [PlayerState.CAST, PlayerState.FISHING, PlayerState.REEL]:
		velocity.x = 0
		move_and_slide()
		return

	move_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	velocity.x = move_dir * speed * delta
	move_and_slide()

	# Cambiar estado según movimiento
	if move_dir != 0:
		_set_state(PlayerState.WALK)
	else:
		_set_state(PlayerState.IDLE)

	# Flip sprite
	if move_dir == 1:
		anim_sprite.flip_h = false
	elif move_dir == -1:
		anim_sprite.flip_h = true

# ===============================
# ANIMACIONES (REFLEJAN ESTADO)
# ===============================
func _update_animation() -> void:
	var anim := ""

	match state:
		PlayerState.IDLE:
			anim = "idle"
		PlayerState.WALK:
			anim = "walk"
		PlayerState.CAST:
			anim = "cast"
		PlayerState.FISHING:
			anim = "fishing"
		PlayerState.REEL:
			anim = "reel"

	if state_machine.get_current_node() != anim:
		state_machine.travel(anim)

# ===============================
# CAMBIO DE ESTADO CENTRALIZADO
# ===============================
func _set_state(new_state: PlayerState) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		PlayerState.CAST:
			# Duración animación cast
			await get_tree().create_timer(0.5).timeout
			_set_state(PlayerState.FISHING)

		PlayerState.REEL:
			# Duración animación reel
			await get_tree().create_timer(0.5).timeout
			_set_state(PlayerState.IDLE)

# ===============================
# AREA DE PESCA
# ===============================
func _on_PuertoArea_body_entered(body: Node) -> void:
	if body == self:
		can_fish = true
		print("Jugador puede pescar")

func _on_PuertoArea_body_exited(body: Node) -> void:
	if body == self:
		can_fish = false
		print("Jugador salió de la zona de pesca")

		# Cancelar pesca inmediatamente
		if state == PlayerState.FISHING:
			_set_state(PlayerState.IDLE)
