extends Control
signal play_signal(mode)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_endless_pressed() -> void:
	emit_signal("play_signal", "endless")

func _on_timed_pressed() -> void:
	emit_signal("play_signal", "timed")

func _on_quit_pressed() -> void:
	get_tree().quit()
