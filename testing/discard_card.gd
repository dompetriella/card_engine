extends Button
class_name DiscardCard

var card_manager: CardManager;

func _ready() -> void:
	card_manager = get_tree().get_nodes_in_group(GlobalGroupNames.CARD_MANAGER)[0];
	
func _process(delta: float) -> void:
	if (card_manager.selected_cards.size() > 0):
		self.text = "Discard " + str(card_manager.selected_cards.size()) + " card(s)"
		return;
	
	self.text = "[ Discard ]"
	

func _on_pressed() -> void:
		
	for card: CardNode in card_manager.selected_cards:
		card_manager.discard_card(card)
