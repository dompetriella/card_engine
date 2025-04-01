extends Node2D
class_name CardNode

var value: int = 0;

@onready var card_collision: CollisionShape2D = %CardCollision
@onready var card_text: Label = $CardText

signal card_focused(card)
signal card_unfocused(card)

func _ready() -> void:
	card_text.text = str(self.value);
	
func get_card_size() -> Vector2:
	var size: Vector2 = card_collision.shape.size;
	return size;
	
func _on_card_area_mouse_entered() -> void:
	self.card_focused.emit(self);
	

func _on_card_area_mouse_exited() -> void:
	self.card_unfocused.emit(self);
