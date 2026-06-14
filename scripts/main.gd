extends Node

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : float = 25.0
var screen_size : Vector2i
var score : int
const SCORE_MODIFIER : int = 70
var game_running : bool
const SPEED_MODIFIER : int = 4000
var stump_scene = preload("res://sence/stump.tscn")
var rock_scene = preload("res://sence/rock.tscn")
var barrel_scene = preload("res://sence/barrel.tscn")
var bird_scene = preload("res://sence/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_height := [200, 390]
var last_obs
var ground_height : int
var difficulty : int
var MAX_DIFFICULTY : int = 2
var high_score : int

func _ready() -> void:
	# ✅ الحل الأساسي: الـ viewport مش الـ window
	screen_size = Vector2i(get_viewport().get_visible_rect().size)
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	$restart.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0

	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	last_obs = null

	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)

	$HUD.get_node("StartLabel").show()
	$restart.hide()

func _process(delta: float) -> void:
	if game_running:
		# ✅ نطبع السرعة على 60 FPS كـ baseline
		var delta_scale = delta * 60.0
		
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED

		score += speed * delta_scale
		adjust_difficulty()
		generate_obs()
		show_score()

		$Dino.position.x += speed * delta_scale
		$Camera2D.position.x += speed * delta_scale

		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x

		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
			
func show_score():
	$HUD.get_node("SocreLabel").text = "Score: " + str(int(score / SCORE_MODIFIER))

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(int(high_score / SCORE_MODIFIER))

func generate_obs():
	if obstacles.is_empty() or last_obs == null or \
	last_obs.position.x < $Camera2D.position.x - randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = int($Camera2D.position.x) + screen_size.x + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - int(obs_height * obs_scale.y) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = int($Camera2D.position.x) + screen_size.x + 100
				var obs_y : int = bird_height[randi() % bird_height.size()]
				add_obs(obs, obs_x, obs_y)
				
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Dino":
		game_over()

func adjust_difficulty():
	difficulty = int(score / SPEED_MODIFIER)
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$restart.show()
