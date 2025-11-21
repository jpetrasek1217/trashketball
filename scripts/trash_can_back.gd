extends Area2D

func _on_area_entered(area: Area2D) -> void:
	area.z_index = 0
	print("changed z_index", area.z_index)
