extends CharacterBody2D

# Variables de uso general
var intVX = 3000
var intMove = 0

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D

# Animation tree
@onready var anim_tree: AnimationTree = $AnimationTree
var state_machine

func _ready() -> void:
	anim_tree.active=true
	state_machine = anim_tree["parameters/playback"]

func _physics_process(_delta):
	# Movimiento
	if Input.is_action_pressed("right") :
		intMove = 1
	elif Input.is_action_pressed("left"):
		intMove = -1
	else:
		intMove = 0

	velocity.x = intVX * intMove * _delta

	# Aplicar movimiento
	move_and_slide()

	# Actualizar animaciones
	animaciones()

func animaciones():
	# Flip horizontal
	if intMove == 1:
		animacion.flip_h = false
	elif intMove==-1:
		animacion.flip_h = true
	# Cambiar animación
	if intMove != 0:
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
