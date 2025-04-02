extends Button
class_name PlayCard

var card_manager: CardManager;

func _ready() -> void:
	card_manager = get_tree().get_first_node_in_group(GlobalGroupNames.CARD_MANAGER);
	
func _process(delta: float) -> void:
	if (card_manager.selected_cards.size() > 0):
		self.text = "Play " + str(card_manager.selected_cards.size()) + " card(s)"
		return;
	
	self.text = "[ Play ]"
	

func _on_pressed() -> void:
	if (card_manager.selected_cards.size() > 0):	card_manager.play_selected_cards();
