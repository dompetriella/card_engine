extends Button
class_name ShuffleDiscardIntoDeck

var card_manager: CardManager;

func _ready() -> void:
	card_manager = get_tree().get_first_node_in_group(GlobalGroupNames.CARD_MANAGER);

func _on_pressed() -> void:
	card_manager.shuffle_discard_pile_into_draw_pile();
