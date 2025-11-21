extends Node2D

var time_passed = 0
var myVelocity: float = 1.0
var myGravity = 2
var float_modulo_thresh = 1e-6
var increasing = true
var scale_throw = 200  # scaling for screen size
var display_pixelated_scale = 1
var debounce_time = 0
var thrown = true
var throwing = false
var game_active = false
var points = PackedVector2Array()
var throw_points = PackedVector2Array()
var display_points = PackedVector2Array()

@onready var trajectory_line: Line2D = $line

signal throw_ball(points: PackedVector2Array)

func _ready():
	draw_parabola(myVelocity, PI/4.0, myGravity, 1/30.0)

func draw_parabola(velocity: float, traj_angle: float, gravity: float, time_step):
	var total_time = 1.2
	points = []
	display_points = []
	
	for t in range(int(total_time / time_step)):
		var time = t * time_step
		var x = velocity * cos(traj_angle) * time
		var y = velocity * sin(traj_angle) * time - 0.5 * gravity * time * time
		if (114 - y * scale_throw > 127):
			break
		# Convert to screen space: Godot's +Y is down, so subtract y
		points.append(Vector2(x * scale_throw + 70, 114 - y * scale_throw)) # 70 and 114 is the right offset for the 2.0 scaling
		display_points.append(Vector2(x * scale_throw + 70, 114 - y * scale_throw))
	trajectory_line.clear_points()
	trajectory_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	trajectory_line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	trajectory_line.points = display_points
	trajectory_line.width = 4.0
	
func _physics_process(delta: float) -> void:
	if not throwing:
		draw_parabola(myVelocity, PI/4, myGravity, delta)
		if Input.is_key_pressed(KEY_SPACE) and game_active:
			throwing = true 
		if increasing:
			myVelocity += delta/1.5
			if myVelocity >= 1.5:
				increasing = false
		else:
			myVelocity -= delta/1.5
			if myVelocity <= 0.75:
				increasing = true
	else:
		if debounce_time == 0:
			throw_points = points
		debounce_time += 1
		if (debounce_time > 12):
			throwing = false 
			debounce_time = 0 

func _on_player_finished_throw_animation() -> void:
	emit_signal("throw_ball", throw_points)

func _on_trashketball_change_game_active(active: bool) -> void:
	game_active = active
