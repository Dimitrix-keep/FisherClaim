extends CharacterBody2D


const SPEED = 50




func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	_animaciones()
	move_and_slide()
	
func _animaciones():
	# 1. Usamos is_action_pressed para que la animación dure mientras mantienes la tecla
	var moviendo := Input.get_axis("ui_left", "ui_right")
	
	if moviendo != 0:
		$AnimatedSprite2D.play("walking") # Método correcto para reproducir
		
		# 2. Control del flip (espejo)
		if moviendo < 0:
			$AnimatedSprite2D.flip_h = true  # Mira a la izquierda
		else:
			$AnimatedSprite2D.flip_h = false # Mira a la derecha
			
		
	else:
		$AnimatedSprite2D.play("idle")
		# print("Quieto")
