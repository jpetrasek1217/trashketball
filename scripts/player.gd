extends CharacterBody2D

const SPEED = 50.0
var game_active = false
signal finished_throw_animation

func _physics_process(_delta):
	var anim = $AnimatedSprite2D
	if Input.is_key_pressed(KEY_SPACE) and game_active:
		anim.play("shoot")

func _on_animated_sprite_2d_animation_finished() -> void:
	emit_signal("finished_throw_animation")


func _on_trashketball_change_game_active(active: bool) -> void:
	game_active = active
