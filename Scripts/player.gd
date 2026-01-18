extends CharacterBody2D

# Estados del jugador

enum PlayerState { IDLE, WALK, CAST, FISHING, REEL }


# Variables exportadas

@export var speed := 3000.0        # Velocidad del jugador
@export var FishScene: PackedScene # Escena del pez (no se usa en pantalla)

# Referencias a nodos

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine = anim_tree["parameters/playback"]
@onready var fish_spawn: Node2D = $FishSpawn

# Variables de estado
var state: PlayerState = PlayerState.IDLE   # Estado actual del jugador
var can_fish := false                      # Si está dentro de zona de pesca
var move_dir := 0                          # Dirección de movimiento (-1,0,1)

@onready var inventory : Inventory = Inventory.new()  # Inventario del jugador

# Variables de pesca
var fish_ready := false            # Si el pez ya mordió
var fish_timer := Timer.new()      # Timer para la mordida
var bite_timer := Timer.new()      # Timer para la ventana de recoger

@export var min_bite_time := 2.0   # Tiempo mínimo para que muerda
@export var max_bite_time := 6.0   # Tiempo máximo para que muerda
@export var bite_window := 1.5     # Ventana para recoger el pez

# READY: Inicialización
func _ready() -> void:
	# Crear inventario y agregarlo al árbol de nodos
	inventory = Inventory.new()
	add_child(inventory)

	# Activar el AnimationTree
	anim_tree.active = true

	# Establecer estado inicial
	_set_state(PlayerState.IDLE)

	# Agregar timers al árbol de nodos
	add_child(fish_timer)
	add_child(bite_timer)

	# Configurar timers para que solo se disparen una vez
	fish_timer.one_shot = true
	bite_timer.one_shot = true

	# Conectar señales timeout a funciones
	fish_timer.connect("timeout", Callable(self, "_on_fish_timer_timeout"))
	bite_timer.connect("timeout", Callable(self, "_on_bite_timer_timeout"))

# PHYSICS_PROCESS: Lógica por frame
func _physics_process(delta: float) -> void:
	_handle_input()       # Leer input del jugador
	_handle_movement(delta) # Mover jugador
	_update_animation()   # Actualizar animación según estado

# INPUT: Control de acciones
func _handle_input() -> void:
	# Si pulsa CAST y puede pescar y está en IDLE
	if Input.is_action_just_pressed("cast") and can_fish and state == PlayerState.IDLE:
		_set_state(PlayerState.CAST)
		return

	# Si pulsa REEL y puede pescar y está pescando
	if Input.is_action_just_pressed("reel") and can_fish and state == PlayerState.FISHING:
		# Si el pez ya mordió
		if fish_ready:
			_spawn_fish()
			_set_state(PlayerState.REEL)
		else:
			print("No hay nada que recoger")
		return

# MOVIMIENTO: Desplazamiento del jugador
func _handle_movement(delta: float) -> void:
	# Si está pescando o en animación de lanzar/recolectar, no se mueve
	if state in [PlayerState.CAST, PlayerState.FISHING, PlayerState.REEL]:
		velocity.x = 0
		move_and_slide()
		return

	# Dirección de movimiento: 1 = derecha, -1 = izquierda
	move_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))

	# Aplicar velocidad
	velocity.x = move_dir * speed * delta
	move_and_slide()

	# Cambiar estado a WALK o IDLE según movimiento
	if move_dir != 0:
		_set_state(PlayerState.WALK)
	else:
		_set_state(PlayerState.IDLE)

	# Voltear sprite según dirección
	if move_dir == 1:
		anim_sprite.flip_h = false
	elif move_dir == -1:
		anim_sprite.flip_h = true

# ANIMACIONES: Cambiar animación
func _update_animation() -> void:
	var anim := ""
	match state:
		PlayerState.IDLE: anim = "idle"
		PlayerState.WALK: anim = "walk"
		PlayerState.CAST: anim = "cast"
		PlayerState.FISHING: anim = "fishing"
		PlayerState.REEL: anim = "reel"

	# Cambiar de animación solo si es diferente
	if state_machine.get_current_node() != anim:
		state_machine.travel(anim)

# ESTADOS: Cambiar estado del jugador
func _set_state(new_state: PlayerState) -> void:
	# Si ya está en el mismo estado, no hacer nada
	if state == new_state:
		return

	state = new_state

	match state:
		# Si entra en CAST, espera 0.5s y luego pasa a FISHING
		PlayerState.CAST:
			await get_tree().create_timer(0.5).timeout
			_set_state(PlayerState.FISHING)

		# Si entra en FISHING, iniciar timer de mordida
		PlayerState.FISHING:
			_start_fish_timer()

		# Si entra en REEL, espera 0.5s y vuelve a IDLE
		PlayerState.REEL:
			await get_tree().create_timer(0.7).timeout
			_set_state(PlayerState.IDLE)

# PESCA: Timer de mordida
func _start_fish_timer() -> void:
	# Resetear flag de mordida
	fish_ready = false

	# Tiempo aleatorio para que muerda
	var t = randf_range(min_bite_time, max_bite_time)
	fish_timer.start(t)

	print("Esperando mordida en ", t, "s")


# CALLBACK: Pez mordió
func _on_fish_timer_timeout() -> void:
	# Activar que el pez está listo para ser recogido
	fish_ready = true
	print("¡Pez mordió! Pulsa REEL")

	# Iniciar timer de ventana para recoger el pez
	bite_timer.start(bite_window)

# CALLBACK: Se acabó el tiempo de recoger
func _on_bite_timer_timeout() -> void:
	# Si aún estaba listo, se escapa
	if fish_ready:
		fish_ready = false
		_set_state(PlayerState.IDLE)

# RECOGER PEZ: Añadir al inventario
func _spawn_fish() -> void:
	# Validar que se haya asignado la escena del pez
	if FishScene == null:
		print("ERROR: No has asignado FishScene en el inspector")
		return

	# Instanciar el pez pero NO añadirlo a la escena
	var fish_instance = FishScene.instantiate()
	fish_instance.queue_free()

	# Añadir el pez al inventario
	inventory.add_item("Fish", 1)
	print("Pez añadido al inventario")

# ZONA DE PESCA: Entrar al área
func _on_PuertoArea_body_entered(body: Node) -> void:
	if body == self:
		can_fish = true
		print("Jugador puede pescar")

# ZONA DE PESCA: Salir del área
func _on_PuertoArea_body_exited(body: Node) -> void:
	if body == self:
		can_fish = false
		print("Jugador salió de la zona de pesca")

		# Si estaba pescando, cancelar timers y volver a IDLE
		if state == PlayerState.FISHING:
			fish_timer.stop()
			bite_timer.stop()
			fish_ready = false
			_set_state(PlayerState.IDLE)
