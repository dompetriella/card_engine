extends Button
class_name DiscardCard


func _on_pressed() -> void:
	var card_manager: CardManager = get_tree().get_nodes_in_group(GlobalGroupNames.CARD_MANAGER)[0];
	var selected_cards_copy := card_manager.selected_cards.duplicate()
	
	for card: CardNode in selected_cards_copy:
		print(card_manager.selected_cards)
		print(card.id)
		card_manager.discard_card(card)
