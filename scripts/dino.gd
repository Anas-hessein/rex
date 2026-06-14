extends CharacterBody2D


const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$Sprite.play("idle")
		else: 
			$RC.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$RC.disabled = true
				$Sprite.play("duck")
			else:
				$Sprite.play("run")
	else:
		$Sprite.play("jump")
	move_and_slide() 
