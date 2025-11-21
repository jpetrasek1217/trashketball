extends Area2D

signal sink_basket_from_front

func _on_area_entered(area: Area2D) -> void:
	emit_signal("sink_basket_from_front")
	area.queue_free()
