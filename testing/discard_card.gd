extends Button
class_name DiscardCard


func _on_pressed() -> void:
	var card_manager: CardManager =  get_tree().get_nodes_in_group(GlobalGroupNames.CARD_MANAGER)[0];
	for card: CardNode in card_manager.selected_cards:
		card_manager.discard_card(card);
