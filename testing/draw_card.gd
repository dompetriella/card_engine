extends Button
class_name DrawCardButton


func _on_pressed() -> void:
	var card_manager: CardManager =  get_tree().get_first_node_in_group(GlobalGroupNames.CARD_MANAGER);
	card_manager.draw_card();
		
