extends Area2D

var total_time = 3.75 
var sinked = false

func _physics_process(delta: float) -> void:
	if sinked:
		total_time += delta
		position.y = self.position.y + total_time*total_time/2
	return

func _on_trash_lid_sink_basket(_x_val) -> void:
	sinked = true
