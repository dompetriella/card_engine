extends Node2D
class_name CardNode

var id: int = 0;

signal card_focused(card)
signal card_unfocused(card)

func _on_card_area_mouse_entered() -> void:
	self.card_focused.emit(self);
	

func _on_card_area_mouse_exited() -> void:
	self.card_unfocused.emit(self);
