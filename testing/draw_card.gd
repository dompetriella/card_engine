extends Button
class_name DrawCardButton


func _on_pressed() -> void:
	var card_manager: CardManager =  get_tree().get_nodes_in_group(GlobalGroupNames.CARD_MANAGER)[0];
	card_manager.draw_card(0);
		
