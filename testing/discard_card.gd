extends Button
class_name DiscardCard

var card_manager: CardManager;

func _ready() -> void:
	card_manager = get_tree().get_first_node_in_group(GlobalGroupNames.CARD_MANAGER);
	
func _process(delta: float) -> void:
	if (card_manager.selected_cards.size() > 0):
		self.text = "Discard " + str(card_manager.selected_cards.size()) + " card(s)"
		return;
	
	self.text = "[ Discard ]"
	

func _on_pressed() -> void:
	card_manager.discard_selected_cards();
