extends Node
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var speed : float
const START_SPEED : float = 10.0 
const MAX_SPEED : int = 25
var screen_size : Vector2i
var score : int
const SCORE_MODIFIRE : int = 70
var game_runing : bool
const SPEED_MODIFIRE : int = 4000
var stump_scene = preload("res://sence/stump.tscn")
var rock_scene = preload("res://sence/rock.tscn")
var barrel_scene = preload("res://sence/barrel.tscn")
var bird_scene = preload("res://sence/bird.tscn")
var obsticle_types := [stump_scene, rock_scene, barrel_scene ]
var obsticls : Array
var bird_height := [200, 390]
var last_obs
var ground_height : int
var difficality 
var MAX_DIFFACLITY : int = 2 
var high_score : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	$restart.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	game_runing = false
	get_tree().paused = false
	difficality = 0
	
	for obs in obsticls:
		obs.queue_free()
	obsticls.clear()
	
	$Dino.position = DINO_START_POS
	$Dino.velocity  = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0,0)
	
	$HUD.get_node("StartLabel").show()
	$restart.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_runing:
		speed = START_SPEED + score / SPEED_MODIFIRE
		score += speed
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_diffecality()
		
		generate_obs()
		
		show_score()
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		if $Camera2D.position.x - $ground.position.x >  screen_size.x *  1.5:
				$ground.position.x += screen_size.x
		
		for obs in obsticls:
			if obs.position.x <  ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
	else:
		if Input.is_action_pressed("ui_accept"):
			game_runing = true
			$HUD.get_node("StartLabel").hide()
	
func show_score():
	$HUD.get_node("SocreLabel").text = "Score: " + str(score / SCORE_MODIFIRE)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIRE)
		

func generate_obs():
	if obsticls.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obsticle_types[randi() % obsticle_types.size()]
		var obs
		var max_obs = difficality + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int  = screen_size.x + score + 100 + ( i * 100 )
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y ) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		
		if difficality == MAX_DIFFACLITY:
			if (randi() % 2 ) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_height[randi() % bird_height.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obsticls.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obsticls.erase(obs)
		

func hit_obs(body):
	if body.name == "Dino":
		game_over()

func adjust_diffecality():
	difficality = score / SPEED_MODIFIRE
	if difficality > MAX_DIFFACLITY:
		difficality = MAX_DIFFACLITY
	
func game_over():
	check_high_score()
	get_tree().paused = true
	game_runing = false
	$restart.show()
