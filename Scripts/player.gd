extends CharacterBody2D

const SPEED = 50.0
var RUN_SPEED_BONUS = 40 # El extra de velocidad
var gravity = 600 # Nota: 60 suele ser muy poco para Godot 4, lo subí a 600


func _physics_process(_delta):
	# 1. Gravedad
	if not is_on_floor():
		velocity.y += gravity * _delta

	# 2. Detectar Dirección y si está corriendo
	var direction = Input.get_axis("left", "right")
	var esta_corriendo = Input.is_action_pressed("run") and direction != 0

	# 3. Calcular Velocidad
	if direction != 0:
		var velocidad_final = SPEED
		if esta_corriendo:
			velocidad_final += RUN_SPEED_BONUS
		velocity.x = direction * velocidad_final
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	_animation(direction, esta_corriendo)
	move_and_slide()
	
func _animation(direction, esta_corriendo):
	if direction != 0:
		if esta_corriendo:
			$AnimatedSprite2D.play("running") # Asegúrate de tener esta animación
		else:
			$AnimatedSprite2D.play("walking")
		
		$AnimatedSprite2D.flip_h = (direction < 0)
	else:
		$AnimatedSprite2D.play("idle")
