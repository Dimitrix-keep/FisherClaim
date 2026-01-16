extends CharacterBody2D

# Variables de uso general
var intVX = 3000
var intMove = 0
var can_fish = false  # True si está en zona de pesca
var is_fishing = false  # True si actualmente está pescando

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D

# Animation tree
@onready var anim_tree: AnimationTree = $AnimationTree
var state_machine

func _ready() -> void:
	anim_tree.active = true
	state_machine = anim_tree["parameters/playback"]

# Señales del Area2D del puerto
func _on_puerto_area_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body == self:
		can_fish = true
		print("Jugador puede pescar")

func _on_puerto_area_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body == self:
		can_fish = false
		print("Jugador salió de la zona de pesca")

		# Si estaba pescando, cancelar pesca
		if is_fishing:
			is_fishing = false
			state_machine.travel("idle")
			print("Pesca cancelada por salir de la zona")

func _physics_process(_delta):
	if is_fishing:
		velocity.x = 0
		move_and_slide()

		if Input.is_action_just_pressed("reel"):
			is_fishing = false
			state_machine.travel("idle")  # Regresa a idle
			animaciones()  # Actualiza flip y animación inmediatamente
		else:
			animaciones()  # Mantener animación de pesca

		
		return

	# Movimiento normal
	if Input.is_action_pressed("right"):
		intMove = 1
	elif Input.is_action_pressed("left"):
		intMove = -1
	else:
		intMove = 0

	velocity.x = intVX * intMove * _delta
	move_and_slide()

	# Lanzar sedal
	if Input.is_action_just_pressed("cast") and can_fish:
		_lanzar_sedal()

	# Actualizar animaciones
	animaciones()
func _debug_estado():
	print("===== Estado del Player =====")
	print("is_fishing:", is_fishing)
	print("can_fish:", can_fish)
	print("intMove:", intMove)
	print("Animación actual:", state_machine.get_current_node())
	print("=============================")

func animaciones():
	# Flip horizontal
	if intMove == 1:
		animacion.flip_h = false
	elif intMove == -1:
		animacion.flip_h = true

	var anim_a_usar = ""

	# Determinar animación
	if is_fishing:
		anim_a_usar = "idle_fishing"
	elif intMove != 0:
		anim_a_usar = "walk"
	else:
		anim_a_usar = "idle"

	# Solo viajar si no estamos ya en esa animación
	if state_machine.get_current_node() != anim_a_usar:
		state_machine.travel(anim_a_usar)

func _lanzar_sedal():
	is_fishing = true
	state_machine.travel("idle_fishing")  # Primero a 'cast'
	print("Sedal lanzado, esperando a recogerlo")

# Señales del Area2D del puerto
func _on_PuertoArea_body_entered(body):
	if body == self:
		can_fish = true
		print("Jugador puede pescar")

func _on_PuertoArea_body_exited(body):
	if body == self:
		can_fish = false
		print("Jugador salió de la zona de pesca")
