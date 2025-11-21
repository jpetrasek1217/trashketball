extends Node2D

@onready var lid_scene = preload("res://scenes/trash_lid.tscn")
@onready var can_scene := preload("res://scenes/trash_can.tscn")

signal sink_basket_from_spawner
var trash_cans := []  # Each element = { can, lid, slot }
var used_slots := [] # true or false
var time_passed := 0.0
var time_until_next_spawn := 3.0
var start_x := 120
var spacing := 20
var y := 116.0
var growing_time := 0.0
var passed := true
var sunk_flag := false
var playing := false

func _ready():
	var count := randi_range(2, 3)
	var slot_indx := [1, 2, 3, 4, 5, 6, 7, 8]
	slot_indx.shuffle()

	for i in range(count):
		var can = can_scene.instantiate()
		can.slot = i
		can.position = Vector2(start_x + i * spacing, y)
		can.scale = Vector2(1,1 )
		add_child(can)

		var lid := lid_scene.instantiate()
		lid.position = Vector2(can.position.x, can.position.y - 200)
		add_child(lid)

		can.connect("sink_basket_from_can", Callable(self, "_on_trash_can_sink_basket"))
		can.connect("sink_basket_from_can", Callable(lid, "_on_trash_lid_sink_basket"))
		used_slots.append(i)

func _physics_process(delta: float) -> void:
	time_passed += delta
	if time_passed >= time_until_next_spawn:
		var new_slot := randi_range(1, 8)
		if new_slot in used_slots:
			return
		time_passed = 0
 
		var can = can_scene.instantiate()
		can.slot = new_slot
		can.position = Vector2(start_x + new_slot * spacing, y)
		add_child(can)

		var lid := lid_scene.instantiate()
		lid.position = Vector2(can.position.x, can.position.y - 200)
		add_child(lid)

		can.connect("sink_basket_from_can", Callable(self, "_on_trash_can_sink_basket"))
		can.connect("sink_basket_from_can", Callable(lid, "_on_trash_lid_sink_basket"))

		trash_cans.append({
			"can": can,
			"lid": lid,
			"slot": new_slot
		})  
		used_slots.append(new_slot)
		return

func _on_trash_can_sink_basket(slot) -> void:
	time_until_next_spawn += randf_range(-1.5, 1.5)
	time_until_next_spawn -= 1.0/30.0
	if time_until_next_spawn <= 0.8:
		time_until_next_spawn = 0.8
	if time_until_next_spawn >= 4:
		time_until_next_spawn = 4
	emit_signal("sink_basket_from_spawner")    
	trash_cans.erase(slot)
	await get_tree().create_timer(2.0).timeout
	used_slots.erase(slot)
