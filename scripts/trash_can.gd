extends Area2D

var shaking := false
var finished := false
var first:= true
var time_passed = 0
var lid_tex := preload("res://assets/sprites/trashCanWithLid.png")
var stable_position = Vector2()
var rand_brightness_adder_r := 0.0
var rand_brightness_adder_g := 0.0
var rand_brightness_adder_b := 0.0
var slot := 0
var growing := true
var growing_time := 0.0
const GROW_FACTOR := 1.0/30.0
signal sink_basket_from_can(x_val)
@onready var lid_sound = $TrashLid

func _ready():
	self.scale = Vector2(0,0)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(sqrt(1.6), sqrt(1.6)), 0.3)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)


func _on_area_entered(area: Area2D) -> void:
	if first:
		area.z_index = 0
		area.scale = Vector2(0.5,0.5)

func _on_area_exited(area: Area2D) -> void:
	if area is Ball:
		if first:
			emit_signal("sink_basket_from_can", slot)
			area.queue_free()
			first = false
	else:
		area.queue_free() 
		lid_sound.pitch_scale = randf_range(0.94, 1.16) 
		lid_sound.volume_db = -6
		lid_sound.play()
		$trashCanFront.texture = lid_tex
		$in_can_collider.call_deferred("set_disabled", true)
		stable_position = self.position 
		shaking = true

func _physics_process(delta: float) -> void:
	if shaking:
		var shake_pos_x = stable_position[0] + randi_range(-4, 4)
		var shake_pos_y = stable_position[1] + randi_range(-3, 3)
		rand_brightness_adder_r =  randi_range(-5, 25)/10.0
		rand_brightness_adder_g =  randi_range(-5, 25)/10.0
		rand_brightness_adder_b =  randi_range(-5, 25)/10.0
		self.position = Vector2(shake_pos_x, shake_pos_y)
		$trashCanFront.modulate = Color(1 + rand_brightness_adder_r, 1 + rand_brightness_adder_g, 1 + rand_brightness_adder_b, 1.0)
		time_passed += delta
	
		if time_passed >= 1:
			queue_free()
			return
		$trashCanFront.modulate.a = 1 - time_passed
		$trashCanBack.modulate.a = 1 - time_passed
		time_passed += delta 
