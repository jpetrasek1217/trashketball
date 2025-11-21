extends Node2D

@onready var ball_scene = preload("res://scenes/ball.tscn")
signal minus_one_life

func _on_trajectory_throw_ball(points: PackedVector2Array) -> void:
	var ball = ball_scene.instantiate()
	ball.missed_shot.connect(_on_missed_shot)
	ball.points = points
	ball.modulate.a = 0
	add_child(ball)

func _on_missed_shot(): 
	emit_signal("minus_one_life") # connect this to the trashketball node and minus a life etc
