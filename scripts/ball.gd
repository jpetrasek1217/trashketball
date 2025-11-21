class_name Ball
extends Area2D

var points: PackedVector2Array = PackedVector2Array()
var points_idx: int = 0
var time_passed = 0 
@onready var throw_sound = $Throw
var first_time_beyond_points = true
signal missed_shot

func _ready() -> void:
	throw_sound.pitch_scale = randf_range(0.94, 1.16) 
	throw_sound.play()

func _physics_process(delta: float) -> void:
	# End when finished path
	if points_idx >= points.size():
		if first_time_beyond_points:
			emit_signal("missed_shot")
			first_time_beyond_points = false
		if time_passed >= 1:
			queue_free()
			return
		$ballSprite.modulate.a = 1.0 - time_passed
		time_passed += delta
		return

	# Move ball
	position = points[points_idx]
	if points_idx == 0:
		modulate.a = 1
	points_idx += 1

	# Out of bounds cleanup
	if is_out_of_bounds():
		queue_free()

func is_out_of_bounds() -> bool:
	return (  
		position.x > 320 or position.x < 0 or
		position.y > 127 or position.y < 0
	)
