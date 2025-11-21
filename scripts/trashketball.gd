extends Node2D

# --- Constants ---
const INITIAL_LIVES := 3
const TIMER_DURATION := 30.0
const WHISTLE_FIRST := 22.5
const WHISTLE_SECOND := 15.0
const WHISTLE_THIRD := 7.5
const LIFE_SPACING := 18
const LIFE_START_X := 308
const LIFE_Y := 10

# --- Game State ---
var sunk_count := 0
var lives := INITIAL_LIVES
var timer := TIMER_DURATION
var global_mode := ""
var time_elapsed := 0.0
var prev_score := 0
var gained_score := 0
var played_high_score_sound := true

# --- Nodes & UI ---
var timer_label: Label
@onready var score_label: Label = $score
@onready var trash_spawner_scene: PackedScene = preload("res://scenes/trash_spawner.tscn")
@onready var life_scene: PackedScene = preload("res://scenes/life.tscn")

# --- Resources ---
var timer_theme: LabelSettings = preload("res://scenes/timer.tres")
var empty_sprite: Texture2D = preload("res://assets/sprites/empty_heart.png")
var buzzer_sound: AudioStream = preload("res://assets/sounds/buzzer.mp3")
var three_whistle_sound: AudioStream = preload("res://assets/sounds/3_whistle.mp3")
var two_whistle_sound: AudioStream = preload("res://assets/sounds/2_whistle.mp3")
var one_whistle_sound: AudioStream = preload("res://assets/sounds/1_whistle.mp3")
var crowd_sound: AudioStream = preload("res://assets/sounds/crowd.mp3")
var ding_sound: AudioStream = preload("res://assets/sounds/ding.mp3")

# --- Flags ---
var played_first_sound := false
var played_second_sound := false
var played_third_sound := false

# --- Scores ---
var endless_high_score := 0
var timed_high_score := 0

# --- Nodes ---
var trash_spawner: Node2D

# --- Signals ---
signal change_game_active(active: bool)

# --- Lifecycle ---
func _ready() -> void:
	score_label.visible = false
	score_label.text = str(sunk_count)
	emit_signal("change_game_active", false)

func _process(delta: float) -> void:
	var score = int(score_label.text)
	if global_mode == "timed" and timer_label:
		if timer <= 0:
			game_over(score, global_mode)
			timer = 0
			global_mode = ""
		timer -= delta
		if timer < 0:
			timer = 0
		_handle_whistles()
		timer_label.text = "%.2f" % timer
	if time_elapsed > 5.0:
		gained_score = score - prev_score 
		if gained_score > 2:
			if global_mode == "endless":
				var container = $LivesOrTimer
				var life = life_scene.instantiate()
				use_tween(life)
				lives += 1
				life.position = Vector2(LIFE_START_X - container.get_child_count() * LIFE_SPACING, LIFE_Y)
				$LivesOrTimer.add_child(life)
			if global_mode == "timed":
				timer += 10.0
			play_sound(ding_sound)
		time_elapsed = 0
		gained_score = 0
		prev_score = score
	if global_mode == "endless" and score > endless_high_score and not played_high_score_sound:
		play_sound(crowd_sound)
		played_high_score_sound = true
	if global_mode == "timed" and score > timed_high_score and not played_high_score_sound:
		play_sound(crowd_sound)
		played_high_score_sound = true

	time_elapsed += delta

# --- Signals ---
func _on_trash_spawner_sink_basket_from_spawner() -> void:
	update_score()

func _on_menu_play_signal(mode: String) -> void:
	global_mode = mode
	if mode == "endless":
		_spawn_lives()
	elif mode == "timed":
		_setup_timer()
	
	trash_spawner = trash_spawner_scene.instantiate()
	trash_spawner.connect("sink_basket_from_spawner", Callable(self, "update_score"))
	add_child(trash_spawner)

	emit_signal("change_game_active", true)
	$Menu.hide()
	score_label.visible = true
	$LivesOrTimer.visible = true

func _on_ball_spawner_minus_one_life() -> void:
	if global_mode == "timed":
		timer -= 3.0
		return

	if lives <= 0:
		return

	lives -= 1
	var container = $LivesOrTimer
	if container.get_child_count() > 0:
		_play_life_whistle(lives)
		var last_life = container.get_child(container.get_child_count() - 1)
		last_life.queue_free()

	if lives == 0:
		game_over(int(score_label.text), global_mode)

# --- Helper Functions ---
func _spawn_lives() -> void:
	if endless_high_score == 0:
		played_high_score_sound = true
	lives = INITIAL_LIVES
	for i in range(lives):
		var life = life_scene.instantiate()
		use_tween(life)
		life.position = Vector2(LIFE_START_X - i * LIFE_SPACING, LIFE_Y)
		$LivesOrTimer.add_child(life)

func _setup_timer() -> void:
	if timed_high_score == 0:
		played_high_score_sound = true
	timer_label = Label.new()
	timer = TIMER_DURATION
	
	timer_label.label_settings = timer_theme
	timer_label.text = "%.2f" % TIMER_DURATION
	timer_label.position = Vector2(285, 0)
	$LivesOrTimer.add_child(timer_label)

func _handle_whistles() -> void:
	if timer > WHISTLE_FIRST:
		played_first_sound = false
	if timer > WHISTLE_SECOND:
		played_second_sound = false
	if timer > WHISTLE_THIRD:
		played_third_sound = false
	if timer <= WHISTLE_FIRST and not played_first_sound:
		#use_tween(timer_label)
		play_sound(one_whistle_sound)
		played_first_sound = true
	if timer <= WHISTLE_SECOND and not played_second_sound:
		#use_tween(timer_label)
		play_sound(two_whistle_sound)
		played_second_sound = true
	if timer <= WHISTLE_THIRD and not played_third_sound:
		#use_tween(timer_label)
		play_sound(three_whistle_sound)
		played_third_sound = true

func _play_life_whistle(current_lives: int) -> void:
	if current_lives == 3:
		play_sound(two_whistle_sound)
	if current_lives == 2:
		play_sound(one_whistle_sound)
	elif current_lives == 1:
		play_sound(three_whistle_sound)

func game_over(score: int, mode: String) -> void:
	emit_signal("change_game_active", false)
	$soundEffects.stream = buzzer_sound
	$soundEffects.play()
	_clear_children(trash_spawner)
	trash_spawner.queue_free()
	_clear_children($LivesOrTimer)
	sunk_count = 0
	score_label.visible = false
	score_label.text = str(sunk_count)   
	played_high_score_sound = false
	
	if mode == "endless":
		if score > endless_high_score:
			endless_high_score = score
		$Menu/HighScore.text = "ENDLESS HIGH SCORE: %d" % endless_high_score
	elif mode == "timed":
		if score > timed_high_score:
			timed_high_score = score
		$Menu/HighScore.text = "TIMED HIGH SCORE: %d" % timed_high_score

	$Menu/Title.text = "GAME OVER"
	$Menu.show()

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func play_sound(stream_link: AudioStream) -> void:
	$soundEffects.stream = stream_link
	$soundEffects.pitch_scale = randf_range(0.94, 1.16)
	$soundEffects.play()

func update_score() -> void:
	score_label.text = str(int(score_label.text) + 1)
	
func use_tween(scene) -> void:
	var tween := create_tween()
	tween.tween_property(scene, "scale", Vector2(sqrt(1.6), sqrt(1.6)), 0.3)
	tween.tween_property(scene, "scale", Vector2(1, 1), 0.1)
