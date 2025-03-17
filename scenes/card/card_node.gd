extends Node2D
class_name CardNode


func _on_card_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		if (event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
			print(self);
